package arch_000092 {

    // Docking Mechanism Reference Architecture 92
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The docking mechanism system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The docking mechanism system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port telemetryOut;
    }

    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port cmdOut;
        port ctrlIn;
    }

    public part def MissionActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port dataOut;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port dataIn;
        port telemetryOut;
    }

    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn;
        port ctrlIn;
    }

    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port statusOut;
        port dataIn;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part commandprocessor : CommandProcessor {
            satisfy REQ_004;
        }
        part monitorsensor : MonitorSensor {
            satisfy REQ_001;
        }
        part missionactuator : MissionActuator {
        }
        part commandcomputer : CommandComputer {
        }
        part commandunit : CommandUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commandsensor : CommandSensor {
            satisfy REQ_002;
        }

        // Connections
        connect monitorsensor.cmdOut to commandcomputer.dataIn;
        connect commandunit.dataIn to missionactuator.dataOut;
    }

    // System Instance
    part dockingmechanismsystem : DockingMechanismSystem;

}