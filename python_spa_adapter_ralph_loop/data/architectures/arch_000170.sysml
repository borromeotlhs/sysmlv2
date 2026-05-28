package arch_000170 {

    // Life Support Reference Architecture 170
    // Domain: life support

    // Requirements
    public requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
        port dataIn;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port pwrOut;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port pwrIn;
        port dataOut;
    }

    // System Definition
    public part def LifeSupportSystem {
        part datapayload : DataPayload {
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_002;
        }
        part distributionbus : DistributionBus {
            satisfy REQ_001;
        }

        // Connections
        connect processingassembly.cmdIn to datapayload.dataIn;
        connect processingassembly.cmdIn to distributionbus.pwrIn;
        connect processingassembly.cmdIn to distributionbus.dataOut;
        connect datapayload.dataIn to distributionbus.dataOut;
    }

    // System Instance
    part lifesupportsystem : LifeSupportSystem;

}