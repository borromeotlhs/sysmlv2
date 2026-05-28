package arch_000138 {

    // Data Processing Unit Reference Architecture 138
    // Domain: data processing unit

    // Requirements
    public requirement REQ_001 {
        doc "The data processing unit system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The data processing unit system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port pwrOut;
    }

    public part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port cmdIn;
        port telemetryOut;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port ctrlIn;
    }

    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port ctrlIn;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port ctrlIn;
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
    part dataprocessingunitsystem : DataProcessingUnitSystem;

}