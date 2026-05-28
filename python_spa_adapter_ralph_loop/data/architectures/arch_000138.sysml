package arch_000138 {

    import ScalarValues::*;

    // Data Processing Unit Reference Architecture 138
    // Domain: data processing unit

    // Requirements
    public requirement REQ_001 {
        doc "The data processing unit system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The data processing unit system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ThermalIF;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : ConfigIF;
        port pwrOut : DataIF;
    }

    public part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DataIF;
        port cmdIn : StatusIF;
        port telemetryOut : SignalIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ConfigIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : PowerIF;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : ConfigIF;
        port ctrlIn : CommandIF;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : SignalIF;
        port ctrlIn : ConfigIF;
    }

    // System Definition
    public part def DataProcessingUnitSystem {
        part navbus : NavBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part commpayload : CommPayload {
        }
        part powerprocessor : PowerProcessor {
        }
        part distributionbus : DistributionBus {
            satisfy REQ_002;
        }
        part commbus : CommBus {
        }
        part commprocessor : CommProcessor {
        }
        part controlactuator : ControlActuator {
        }

        // Connections
        connect powerprocessor.statusOut to navbus.dataIn;
        connect commpayload.pwrOut to powerprocessor.cmdIn;
        connect distributionbus.ctrlIn to commpayload.ctrlIn;
        connect commprocessor.ctrlIn to powerprocessor.cmdIn;
        connect commpayload.pwrOut to distributionbus.ctrlIn;
    }

    // System Instance
    public part dataprocessingunitsystem : DataProcessingUnitSystem;

}