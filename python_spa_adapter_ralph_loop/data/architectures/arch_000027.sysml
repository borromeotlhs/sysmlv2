package arch_000027 {

    import ScalarValues::*;

    // Telemetry System Reference Architecture 27
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
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;

    // Component Definitions
    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : SignalIF;
        port pwrOut : PowerIF;
    }

    public part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : DataIF;
        port cmdOut : DataIF;
        port cmdOut : StatusIF;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut : PowerIF;
    }

    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : DiagnosticIF;
        port sensorOut : ConfigIF;
        port pwrOut : DataIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : StatusIF;
        port cmdIn : SignalIF;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part datasubsystem : DataSubsystem {
            satisfy REQ_003;
        }
        part thermalpayload : ThermalPayload {
            satisfy REQ_003;
        }
        part commsubsystem : CommSubsystem {
        }
        part processingcontroller : ProcessingController {
            satisfy REQ_001;
        }
        part thermalsubsystem : ThermalSubsystem {
            satisfy REQ_002;
        }

        // Connections
        connect commsubsystem.pwrOut to datasubsystem.pwrOut;
        connect processingcontroller.pwrOut to thermalpayload.cmdOut;
        connect thermalsubsystem.cmdIn to processingcontroller.sensorOut;
        connect processingcontroller.pwrOut to commsubsystem.pwrOut;
    }

    // System Instance
    public part telemetrysystemsystem : TelemetrySystemSystem;

}