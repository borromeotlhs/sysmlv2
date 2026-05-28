package arch_000008 {

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

    // Component Definitions
    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port cmdIn;
        port pwrOut;
    }

    public part def ThermalModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port ctrlIn;
        port statusOut;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
        port cmdIn;
        port configIn;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
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
    part propulsionmodulesystem : PropulsionModuleSystem;

}