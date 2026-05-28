package arch_000101 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut : ConfigIF;
        port pwrIn : StatusIF;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : PowerIF;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : DataIF;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DiagnosticIF;
        port ctrlIn : SignalIF;
        port configIn : TelemetryIF;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : CommandIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : ConfigIF;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DataIF;
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
    public part reactionwheelsystem : ReactionWheelSystem;

}