package arch_000067 {

    // Telemetry System Reference Architecture 67
    // Domain: telemetry system

    // Requirements
    requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The telemetry system system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrOut;
    }

    part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port cmdOut;
        port cmdOut;
    }

    part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut;
    }

    part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port sensorOut;
        port pwrOut;
    }

    part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port cmdIn;
    }

    // System Definition
    part def TelemetrySystemSystem {
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
    part telemetrysystemsystem : TelemetrySystemSystem;

}