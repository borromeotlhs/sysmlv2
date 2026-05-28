package arch_000046 {

    import ScalarValues::*;

    // Telemetry System Reference Architecture 46
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : PowerIF;
        port telemetryOut : StatusIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : TelemetryIF;
        port statusOut : StatusIF;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : ConfigIF;
    }

    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ControlIF;
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
    public part telemetrysystemsystem : TelemetrySystemSystem;

}