package arch_000103 {

    // Telemetry System Reference Architecture 103
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port dataIn;
        port cmdOut;
    }

    public part def ControlController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn;
    }

    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn;
        port telemetryOut;
        port cmdIn;
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
    part telemetrysystemsystem : TelemetrySystemSystem;

}