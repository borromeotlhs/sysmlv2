package arch_000094 {

    // Avionics Bay Reference Architecture 94
    // Domain: avionics bay

    // Requirements
    requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    requirement REQ_004 {
        doc "The avionics bay system shall maintain operational status monitoring."
    }

    // Component Definitions
    part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port configIn;
    }

    part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port dataIn;
    }

    // System Definition
    part def AvionicsBaySystem {
        part controlprocessor : ControlProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect controlprocessor.configIn to dataprocessor.pwrIn;
        connect controlprocessor.telemetryOut to dataprocessor.pwrIn;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}