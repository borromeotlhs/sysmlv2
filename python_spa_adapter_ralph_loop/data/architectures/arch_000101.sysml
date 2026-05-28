package arch_000101 {

    // Reaction Wheel Reference Architecture 101
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The reaction wheel system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut;
        port pwrIn;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
        port configIn;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part commsubsystem : CommSubsystem {
        }
        part dataunit : DataUnit {
        }
        part flightsubsystem : FlightSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part monitormodule : MonitorModule {
            satisfy REQ_001;
        }
        part sensoractuator : SensorActuator {
        }
        part distributionbus : DistributionBus {
        }
        part monitorunit : MonitorUnit {
            satisfy REQ_003;
        }

        // Connections
        connect monitormodule.ctrlIn to dataunit.cmdOut;
        connect commsubsystem.telemetryOut to flightsubsystem.pwrIn;
        connect dataunit.cmdOut to commsubsystem.telemetryOut;
        connect flightsubsystem.pwrIn to monitormodule.ctrlIn;
    }

    // System Instance
    part reactionwheelsystem : ReactionWheelSystem;

}