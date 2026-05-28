package arch_000144 {

    import ScalarValues::*;

    // Antenna Subsystem Reference Architecture 144
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : StatusIF;
    }

    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : DiagnosticIF;
        port telemetryOut : TelemetryIF;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : ConfigIF;
        port configIn : TelemetryIF;
        port ctrlIn : ConfigIF;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : CommandIF;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : TelemetryIF;
        port configIn : StatusIF;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part missioncomputer : MissionComputer {
            satisfy REQ_002;
        }
        part commandsensor : CommandSensor {
        }
        part monitorunit : MonitorUnit {
        }
        part processingprocessor : ProcessingProcessor {
            satisfy REQ_002;
        }
        part navsubsystem : NavSubsystem {
            satisfy REQ_001;
        }

        // Connections
        connect missioncomputer.pwrIn to commandsensor.telemetryOut;
        connect monitorunit.ctrlIn to missioncomputer.pwrIn;
        connect monitorunit.ctrlIn to processingprocessor.sensorOut;
        connect monitorunit.configIn to commandsensor.cmdOut;
    }

    // System Instance
    public part antennasubsystemsystem : AntennaSubsystemSystem;

}