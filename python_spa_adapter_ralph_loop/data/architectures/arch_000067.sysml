package arch_000067 {

    import ScalarValues::*;

    // Robotic Arm Reference Architecture 67
    // Domain: robotic arm

    // Requirements
    public requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;

    // Component Definitions
    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : PowerIF;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : ControlIF;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : DataIF;
        port configIn : DiagnosticIF;
        port pwrIn : DataIF;
    }

    // System Definition
    public part def RoboticArmSystem {
        part flightpayload : FlightPayload {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part flightprocessor : FlightProcessor {
            satisfy REQ_003;
        }
        part flightcomputer : FlightComputer {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect flightpayload.dataOut to flightprocessor.statusOut;
        connect flightcomputer.configIn to flightprocessor.statusOut;
    }

    // System Instance
    public part roboticarmsystem : RoboticArmSystem;

}