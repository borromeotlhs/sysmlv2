package arch_000068 {

    // Radar System Reference Architecture 68
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The radar system system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The radar system system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
        port pwrIn;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port configIn;
    }

    // System Definition
    public part def RadarSystemSystem {
        part comminterface : CommInterface {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part commprocessor : CommProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect comminterface.pwrIn to commprocessor.configIn;
        connect commprocessor.dataIn to comminterface.pwrIn;
        connect commprocessor.dataIn to comminterface.dataOut;
    }

    // System Instance
    part radarsystemsystem : RadarSystemSystem;

}