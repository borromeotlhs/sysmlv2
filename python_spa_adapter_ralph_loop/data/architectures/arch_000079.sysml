package arch_000079 {

    import ScalarValues::*;

    // Battery Management Reference Architecture 79
    // Domain: battery management

    // Requirements
    public requirement REQ_001 {
        doc "The battery management system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The battery management system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;

    // Component Definitions
    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : SignalIF;
        port dataIn : DataIF;
        port statusOut : ConfigIF;
    }

    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
        port cmdOut : CommandIF;
        port pwrIn : SignalIF;
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
    public part batterymanagementsystem : BatteryManagementSystem;

}