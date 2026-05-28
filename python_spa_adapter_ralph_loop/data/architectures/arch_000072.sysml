package arch_000072 {

    import ScalarValues::*;

    // Data Processing Unit Reference Architecture 72
    // Domain: data processing unit

    // Requirements
    public requirement REQ_001 {
        doc "The data processing unit system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The data processing unit system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The data processing unit system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut : SignalIF;
        port pwrIn : ThermalIF;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : StatusIF;
    }

    public part def ProcessingSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : TelemetryIF;
        port dataIn : CommandIF;
        port pwrOut : CommandIF;
    }

    // System Definition
    public part def DataProcessingUnitSystem {
        part commbus : CommBus {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part sensorbus : SensorBus {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part processingsensor : ProcessingSensor {
        }

        // Connections
        connect commbus.telemetryOut to sensorbus.cmdIn;
        connect processingsensor.sensorOut to commbus.pwrIn;
        connect commbus.pwrIn to processingsensor.pwrOut;
        connect commbus.telemetryOut to processingsensor.sensorOut;
        connect sensorbus.cmdIn to processingsensor.sensorOut;
    }

    // System Instance
    public part dataprocessingunitsystem : DataProcessingUnitSystem;

}