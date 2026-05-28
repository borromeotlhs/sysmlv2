package arch_000099 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 99
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : SignalIF;
        port ctrlIn : ControlIF;
        port configIn : ConfigIF;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : PowerIF;
        port dataIn : CommandIF;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataOut : SignalIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut : ThermalIF;
        port dataIn : StatusIF;
        port cmdOut : DataIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part dataassembly : DataAssembly {
        }
        part thermalinterface : ThermalInterface {
            satisfy REQ_002;
        }
        part powerbus : PowerBus {
            satisfy REQ_001;
        }
        part poweractuator : PowerActuator {
            satisfy REQ_001;
        }

        // Connections
        connect thermalinterface.dataIn to dataassembly.configIn;
        connect poweractuator.cmdOut to thermalinterface.dataIn;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}