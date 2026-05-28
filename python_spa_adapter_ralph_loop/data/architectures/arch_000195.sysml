package arch_000195 {

    // Command Data Handling Reference Architecture 195
    // Domain: command data handling

    // Requirements
    public requirement REQ_001 {
        doc "The command data handling system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The command data handling system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The command data handling system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port statusOut;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port cmdIn;
        port statusOut;
    }

    // System Definition
    public part def CommandDataHandlingSystem {
        part processingassembly : ProcessingAssembly {
        }
        part missionprocessor : MissionProcessor {
        }
        part monitormodule : MonitorModule {
            satisfy REQ_001;
        }
        part navinterface : NavInterface {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part powercontroller : PowerController {
        }

        // Connections
        connect powercontroller.cmdIn to processingassembly.ctrlIn;
        connect powercontroller.statusOut to missionprocessor.statusOut;
    }

    // System Instance
    part commanddatahandlingsystem : CommandDataHandlingSystem;

}