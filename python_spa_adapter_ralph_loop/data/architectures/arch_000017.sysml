package arch_000017 {

    import ScalarValues::*;

    // Robotic Arm Reference Architecture 17
    // Domain: robotic arm

    // Requirements
    public requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : TelemetryIF;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : DiagnosticIF;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port ctrlIn : TelemetryIF;
        port ctrlIn : ControlIF;
    }

    // System Definition
    public part def RoboticArmSystem {
        part powercomputer : PowerComputer {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part missionsensor : MissionSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part powerbus : PowerBus {
            satisfy REQ_001;
        }

        // Connections
        connect powercomputer.telemetryOut to powerbus.ctrlIn;
        connect missionsensor.cmdIn to powercomputer.telemetryOut;
        connect powerbus.ctrlIn to missionsensor.cmdIn;
    }

    // System Instance
    public part roboticarmsystem : RoboticArmSystem;

}