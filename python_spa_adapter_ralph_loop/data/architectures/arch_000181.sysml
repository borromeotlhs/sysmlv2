package arch_000181 {

    import ScalarValues::*;

    // Telemetry System Reference Architecture 181
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The telemetry system system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def PowerIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : PowerIF;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : TelemetryIF;
        port pwrIn : TelemetryIF;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part distributionunit : DistributionUnit {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part controlsensor : ControlSensor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect distributionunit.sensorOut to controlsensor.statusOut;
        connect distributionunit.sensorOut to controlsensor.pwrIn;
    }

    // System Instance
    public part telemetrysystemsystem : TelemetrySystemSystem;

}