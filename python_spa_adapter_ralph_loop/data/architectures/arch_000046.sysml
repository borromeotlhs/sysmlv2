package arch_000046 {

    // Telemetry System Reference Architecture 46
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port telemetryOut;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port statusOut;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part processingcontroller : ProcessingController {
            satisfy REQ_002;
        }
        part sensorcomputer : SensorComputer {
        }
        part flightpayload : FlightPayload {
            satisfy REQ_001;
        }
        part missionunit : MissionUnit {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect processingcontroller.telemetryOut to flightpayload.telemetryOut;
        connect missionunit.telemetryOut to processingcontroller.telemetryOut;
    }

    // System Instance
    part telemetrysystemsystem : TelemetrySystemSystem;

}