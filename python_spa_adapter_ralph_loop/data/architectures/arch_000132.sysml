package arch_000132 {

    // Ground Station Reference Architecture 132
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
        port configIn;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port configIn;
        port dataOut;
    }

    // System Definition
    public part def GroundStationSystem {
        part navpayload : NavPayload {
        }
        part commprocessor : CommProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect navpayload.configIn to commprocessor.dataOut;
        connect navpayload.dataOut to commprocessor.configIn;
        connect navpayload.configIn to commprocessor.configIn;
        connect commprocessor.dataOut to navpayload.dataOut;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}