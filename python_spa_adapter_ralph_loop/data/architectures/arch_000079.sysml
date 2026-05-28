package arch_000079 {

    // Battery Management Reference Architecture 79
    // Domain: battery management

    // Requirements
    public requirement REQ_001 {
        doc "The battery management system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The battery management system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port dataIn;
        port statusOut;
    }

    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port cmdOut;
        port pwrIn;
    }

    // System Definition
    public part def BatteryManagementSystem {
        part monitorbus : MonitorBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part datamodule : DataModule {
        }

        // Connections
        connect monitorbus.statusOut to datamodule.pwrIn;
        connect datamodule.pwrIn to monitorbus.pwrOut;
        connect monitorbus.dataIn to datamodule.pwrIn;
        connect monitorbus.pwrOut to datamodule.cmdOut;
        connect monitorbus.statusOut to datamodule.cmdOut;
    }

    // System Instance
    part batterymanagementsystem : BatteryManagementSystem;

}