package arch_000099 {

    // Communication Relay Reference Architecture 99
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port ctrlIn;
        port configIn;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port dataIn;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataOut;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut;
        port dataIn;
        port cmdOut;
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
    part communicationrelaysystem : CommunicationRelaySystem;

}