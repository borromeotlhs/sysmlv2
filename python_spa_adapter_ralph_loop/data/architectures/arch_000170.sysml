package arch_000170 {

    import ScalarValues::*;

    // Life Support Reference Architecture 170
    // Domain: life support

    // Requirements
    public requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : StatusIF;
        port dataIn : CommandIF;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : DataIF;
        port pwrOut : CommandIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : PowerIF;
        port pwrIn : TelemetryIF;
        port dataOut : DiagnosticIF;
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
    public part lifesupportsystem : LifeSupportSystem;

}