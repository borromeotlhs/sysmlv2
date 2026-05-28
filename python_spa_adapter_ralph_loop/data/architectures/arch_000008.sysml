package arch_000008 {

    // Propulsion Module Reference Architecture 8
    // Domain: propulsion module

    // Requirements
    requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The propulsion module system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port cmdIn;
        port pwrOut;
    }

    part def ThermalModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port ctrlIn;
        port statusOut;
    }

    part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
        port cmdIn;
        port configIn;
    }

    part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    // System Definition
    part def PropulsionModuleSystem {
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