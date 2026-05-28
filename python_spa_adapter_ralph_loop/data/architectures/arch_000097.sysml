package arch_000097 {

    import ScalarValues::*;

    // Autonomous Rover Reference Architecture 97
    // Domain: autonomous rover

    // Requirements
    public requirement REQ_001 {
        doc "The autonomous rover system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The autonomous rover system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : TelemetryIF;
        port pwrOut : CommandIF;
        port cmdIn : ThermalIF;
    }

    public part def NavSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : DataIF;
        port pwrOut : ControlIF;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : PowerIF;
        port sensorOut : SignalIF;
        port dataOut : SignalIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ControlIF;
        port pwrOut : PowerIF;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : ThermalIF;
        port statusOut : ControlIF;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : SignalIF;
        port ctrlIn : PowerIF;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part distributionsubsystem : DistributionSubsystem {
        }
        part navsensor : NavSensor {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part missionsensor : MissionSensor {
        }
        part thermalsubsystem : ThermalSubsystem {
            satisfy REQ_002;
        }
        part monitorprocessor : MonitorProcessor {
        }
        part navcontroller : NavController {
            satisfy REQ_001;
        }

        // Connections
        connect thermalsubsystem.pwrOut to monitorprocessor.statusOut;
        connect navcontroller.ctrlIn to distributionsubsystem.pwrOut;
        connect navcontroller.statusOut to navsensor.configIn;
    }

    // System Instance
    public part autonomousroversystem : AutonomousRoverSystem;

}