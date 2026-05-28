package arch_000152 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : StatusIF;
        port dataIn : ControlIF;
        port ctrlIn : PowerIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut : TelemetryIF;
        port cmdIn : ThermalIF;
        port dataIn : CommandIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataIn : CommandIF;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
        port ctrlIn : StatusIF;
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
    public part radarsystemsystem : RadarSystemSystem;

}