package arch_000123 {

    // Radar System Reference Architecture 123
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ProcessingInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port pwrOut;
        port pwrIn;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port cmdIn;
        port configIn;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdIn;
        port configIn;
        port pwrIn;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    // System Definition
    public part def RadarSystemSystem {
        part processinginterface : ProcessingInterface {
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_002;
        }
        part monitorinterface : MonitorInterface {
            satisfy REQ_002;
        }
        part sensoractuator : SensorActuator {
        }
        part poweractuator : PowerActuator {
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_001;
        }
        part sensorcomputer : SensorComputer {
        }

        // Connections
        connect poweractuator.cmdIn to monitorcontroller.pwrIn;
        connect sensorcomputer.pwrIn to monitorcontroller.pwrIn;
        connect poweractuator.pwrIn to processinginterface.ctrlIn;
    }

    // System Instance
    part radarsystemsystem : RadarSystemSystem;

}