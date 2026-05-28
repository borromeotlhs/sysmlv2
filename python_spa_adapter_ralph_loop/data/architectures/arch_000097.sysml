package arch_000097 {

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

    // Component Definitions
    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port pwrOut;
        port cmdIn;
    }

    public part def NavSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port pwrOut;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port sensorOut;
        port dataOut;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port pwrOut;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port statusOut;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port ctrlIn;
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
    part autonomousroversystem : AutonomousRoverSystem;

}