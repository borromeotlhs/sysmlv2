package arch_000008 {

    import ScalarValues::*;

    // Propulsion Module Reference Architecture 8
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The propulsion module system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;

    // Component Definitions
    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : SignalIF;
        port cmdIn : CommandIF;
        port pwrOut : PowerIF;
    }

    public part def ThermalModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
        port ctrlIn : ConfigIF;
        port statusOut : ConfigIF;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : DataIF;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn : ConfigIF;
        port cmdIn : ControlIF;
        port configIn : ConfigIF;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : PowerIF;
    }

    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : ControlIF;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part databus : DataBus {
            satisfy REQ_003;
        }
        part thermalmodule : ThermalModule {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitorinterface : MonitorInterface {
        }
        part powersensor : PowerSensor {
        }
        part navunit : NavUnit {
        }
        part missioncontroller : MissionController {
        }

        // Connections
        connect navunit.statusOut to thermalmodule.pwrIn;
        connect databus.cmdIn to thermalmodule.statusOut;
    }

    // System Instance
    public part propulsionmodulesystem : PropulsionModuleSystem;

}