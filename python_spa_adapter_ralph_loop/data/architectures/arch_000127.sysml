package arch_000127 {

    // Battery Management Reference Architecture 127
    // Domain: battery management

    // Requirements
    public requirement REQ_001 {
        doc "The battery management system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The battery management system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The battery management system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port ctrlIn;
        port telemetryOut;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port cmdIn;
        port cmdIn;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
    }

    // System Definition
    public part def BatteryManagementSystem {
        part powerbus : PowerBus {
            satisfy REQ_003;
        }
        part commcontroller : CommController {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part monitorbus : MonitorBus {
        }

        // Connections
        connect commcontroller.cmdIn to monitorbus.ctrlIn;
        connect commcontroller.cmdIn to powerbus.ctrlIn;
    }

    // System Instance
    part batterymanagementsystem : BatteryManagementSystem;

}