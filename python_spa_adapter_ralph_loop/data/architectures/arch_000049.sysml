package arch_000049 {

    // Propulsion Module Reference Architecture 49
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port configIn;
        port statusOut;
    }

    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port statusOut;
        port sensorOut;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part datamodule : DataModule {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part processingcontroller : ProcessingController {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect processingcontroller.pwrOut to datamodule.ctrlIn;
        connect processingcontroller.statusOut to datamodule.configIn;
        connect processingcontroller.pwrOut to datamodule.statusOut;
        connect datamodule.configIn to processingcontroller.pwrOut;
    }

    // System Instance
    part propulsionmodulesystem : PropulsionModuleSystem;

}