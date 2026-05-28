package arch_000105 {

    // Avionics Bay Reference Architecture 105
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The avionics bay system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port sensorOut;
        port configIn;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part commandcomputer : CommandComputer {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part datacontroller : DataController {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part navmodule : NavModule {
            satisfy REQ_003;
        }

        // Connections
        connect commandcomputer.cmdIn to datacontroller.statusOut;
        connect datacontroller.configIn to commandcomputer.cmdIn;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}