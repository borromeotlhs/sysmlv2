package arch_000022 {

    import ScalarValues::*;

    // Sensor Suite Reference Architecture 22
    // Domain: sensor suite

    // Requirements
    public requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The sensor suite system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : DataIF;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : DiagnosticIF;
        port telemetryOut : ThermalIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : TelemetryIF;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : TelemetryIF;
        port pwrIn : CommandIF;
        port ctrlIn : SignalIF;
    }

    // System Definition
    public part def SensorSuiteSystem {
        part commprocessor : CommProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part datasensor : DataSensor {
        }
        part commactuator : CommActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitorprocessor : MonitorProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect datasensor.statusOut to monitorprocessor.ctrlIn;
        connect commactuator.dataOut to monitorprocessor.pwrIn;
        connect monitorprocessor.ctrlIn to commactuator.dataOut;
    }

    // System Instance
    public part sensorsuitesystem : SensorSuiteSystem;

}