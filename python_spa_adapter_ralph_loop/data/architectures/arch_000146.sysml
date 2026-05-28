package arch_000146 {

    // Data Processing Unit Reference Architecture 146
    // Domain: data processing unit

    // Requirements
    public requirement REQ_001 {
        doc "The data processing unit system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The data processing unit system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut;
        port configIn;
        port dataOut;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port configIn;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port sensorOut;
        port pwrOut;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port statusOut;
        port pwrOut;
    }

    // System Definition
    public part def DataProcessingUnitSystem {
        part communit : CommUnit {
        }
        part controlsensor : ControlSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part navinterface : NavInterface {
        }
        part distributionsensor : DistributionSensor {
        }
        part commandcomputer : CommandComputer {
        }

        // Connections
        connect navinterface.sensorOut to controlsensor.configIn;
        connect commandcomputer.statusOut to communit.dataOut;
        connect controlsensor.telemetryOut to navinterface.sensorOut;
    }

    // System Instance
    part dataprocessingunitsystem : DataProcessingUnitSystem;

}