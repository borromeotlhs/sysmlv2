package arch_000017 {

    // Robotic Arm Reference Architecture 17
    // Domain: robotic arm

    // Requirements
    requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
    }

    part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn;
    }

    part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    // System Definition
    part def RoboticArmSystem {
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
    part roboticarmsystem : RoboticArmSystem;

}