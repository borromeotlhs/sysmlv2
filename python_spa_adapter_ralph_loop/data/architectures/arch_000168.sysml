package arch_000168 {

    import ScalarValues::*;

    // Guidance Navigation Reference Architecture 168
    // Domain: guidance navigation

    // Requirements
    public requirement REQ_001 {
        doc "The guidance navigation system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The guidance navigation system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : StatusIF;
    }

    public part def MissionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : DiagnosticIF;
        port statusOut : ThermalIF;
    }

    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DiagnosticIF;
        port cmdIn : TelemetryIF;
        port statusOut : TelemetryIF;
    }

    public part def ControlInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : DiagnosticIF;
        port cmdOut : ControlIF;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
        port ctrlIn : ConfigIF;
        port pwrOut : DiagnosticIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : DataIF;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : DataIF;
    }

    // System Definition
    public part def GuidanceNavigationSystem {
        part flightprocessor : FlightProcessor {
            satisfy REQ_002;
        }
        part missionpayload : MissionPayload {
            satisfy REQ_001;
        }
        part missionunit : MissionUnit {
        }
        part controlinterface : ControlInterface {
        }
        part commcontroller : CommController {
        }
        part flightinterface : FlightInterface {
        }
        part missionsensor : MissionSensor {
        }

        // Connections
        connect commcontroller.ctrlIn to missionpayload.statusOut;
        connect commcontroller.telemetryOut to missionunit.cmdIn;
        connect flightinterface.cmdOut to commcontroller.ctrlIn;
    }

    // System Instance
    public part guidancenavigationsystem : GuidanceNavigationSystem;

}