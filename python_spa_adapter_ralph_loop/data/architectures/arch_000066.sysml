package arch_000066 {

    import ScalarValues::*;

    // Telemetry System Reference Architecture 66
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
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn : DiagnosticIF;
    }

    public part def PowerUnit {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataIn : DataIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : TelemetryIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : DataIF;
        port sensorOut : ControlIF;
    }

    public part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : SignalIF;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : DataIF;
        port cmdOut : PowerIF;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : DiagnosticIF;
        port cmdIn : ThermalIF;
        port pwrOut : PowerIF;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part commandmodule : CommandModule {
        }
        part powerunit : PowerUnit {
            satisfy REQ_001;
        }
        part thermalsubsystem : ThermalSubsystem {
        }
        part processingbus : ProcessingBus {
            satisfy REQ_002;
        }
        part thermalassembly : ThermalAssembly {
            satisfy REQ_003;
        }
        part navunit : NavUnit {
            satisfy REQ_003;
        }
        part datacontroller : DataController {
            satisfy REQ_001;
        }

        // Connections
        connect processingbus.statusOut to thermalassembly.ctrlIn;
        connect datacontroller.pwrIn to commandmodule.dataIn;
    }

    // System Instance
    public part telemetrysystemsystem : TelemetrySystemSystem;

}