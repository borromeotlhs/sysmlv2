package arch_000152 {

    // Radar System Reference Architecture 152
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

    // Component Definitions
    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port dataIn;
        port ctrlIn;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut;
        port cmdIn;
        port dataIn;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataIn;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port ctrlIn;
    }

    // System Definition
    public part def RadarSystemSystem {
        part processingassembly : ProcessingAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part communit : CommUnit {
        }
        part poweractuator : PowerActuator {
            satisfy REQ_001;
        }
        part distributionunit : DistributionUnit {
            satisfy REQ_003;
        }

        // Connections
        connect distributionunit.pwrIn to processingassembly.pwrOut;
        connect communit.dataIn to distributionunit.ctrlIn;
    }

    // System Instance
    part radarsystemsystem : RadarSystemSystem;

}