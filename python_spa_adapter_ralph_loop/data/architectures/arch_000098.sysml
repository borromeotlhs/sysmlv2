package arch_000098 {

    import ScalarValues::*;

    // Telemetry System Reference Architecture 98
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
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn : CommandIF;
        port statusOut : DataIF;
        port dataIn : CommandIF;
    }

    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : TelemetryIF;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : TelemetryIF;
        port pwrOut : SignalIF;
        port pwrOut : ControlIF;
    }

    public part def DistributionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : SignalIF;
        port pwrOut : CommandIF;
        port statusOut : DataIF;
    }

    public part def PowerUnit {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port telemetryOut : DiagnosticIF;
        port dataOut : DiagnosticIF;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part commandinterface : CommandInterface {
            satisfy REQ_003;
        }
        part sensorsensor : SensorSensor {
            satisfy REQ_001;
        }
        part processingassembly : ProcessingAssembly {
        }
        part distributionpayload : DistributionPayload {
            satisfy REQ_002;
        }
        part powerunit : PowerUnit {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect processingassembly.pwrOut to powerunit.telemetryOut;
        connect distributionpayload.sensorOut to powerunit.dataOut;
        connect commandinterface.statusOut to processingassembly.pwrOut;
    }

    // System Instance
    public part telemetrysystemsystem : TelemetrySystemSystem;

}