package arch_000103 {

    import ScalarValues::*;

    // Telemetry System Reference Architecture 103
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : DiagnosticIF;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DiagnosticIF;
        port dataIn : ControlIF;
        port cmdOut : ThermalIF;
    }

    public part def ControlController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn : DataIF;
    }

    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn : ControlIF;
        port telemetryOut : CommandIF;
        port cmdIn : ControlIF;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part missionprocessor : MissionProcessor {
            satisfy REQ_002;
        }
        part distributionunit : DistributionUnit {
        }
        part controlcontroller : ControlController {
            satisfy REQ_001;
        }
        part commmodule : CommModule {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect commmodule.cmdIn to distributionunit.cmdOut;
        connect distributionunit.cmdOut to missionprocessor.cmdIn;
        connect commmodule.configIn to distributionunit.dataIn;
    }

    // System Instance
    public part telemetrysystemsystem : TelemetrySystemSystem;

}