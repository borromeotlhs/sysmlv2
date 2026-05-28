package arch_000146 {

    import ScalarValues::*;

    // Data Processing Unit Reference Architecture 146
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
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut : PowerIF;
        port configIn : TelemetryIF;
        port dataOut : TelemetryIF;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : ConfigIF;
        port configIn : StatusIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : CommandIF;
        port sensorOut : ThermalIF;
        port pwrOut : TelemetryIF;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : PowerIF;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : SignalIF;
        port statusOut : StatusIF;
        port pwrOut : DataIF;
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
    public part dataprocessingunitsystem : DataProcessingUnitSystem;

}