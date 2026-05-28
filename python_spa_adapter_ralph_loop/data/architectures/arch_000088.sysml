package arch_000088 {

    import ScalarValues::*;

    // Reaction Wheel Reference Architecture 88
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : ConfigIF;
    }

    public part def PowerInterface {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut : CommandIF;
    }

    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn : DiagnosticIF;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : ConfigIF;
        port cmdOut : SignalIF;
    }

    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : ThermalIF;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part distributionsensor : DistributionSensor {
            satisfy REQ_001;
        }
        part powerinterface : PowerInterface {
            satisfy REQ_001;
        }
        part commandunit : CommandUnit {
            satisfy REQ_002;
        }
        part monitorbus : MonitorBus {
        }
        part monitorassembly : MonitorAssembly {
            satisfy REQ_002;
        }

        // Connections
        connect monitorassembly.pwrOut to monitorbus.cmdOut;
        connect powerinterface.cmdOut to monitorbus.cmdOut;
        connect powerinterface.cmdOut to distributionsensor.sensorOut;
        connect distributionsensor.sensorOut to monitorbus.cmdOut;
        connect distributionsensor.sensorOut to commandunit.configIn;
    }

    // System Instance
    public part reactionwheelsystem : ReactionWheelSystem;

}