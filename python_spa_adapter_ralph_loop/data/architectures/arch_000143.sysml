package arch_000143 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 143
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The ground station system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;

    // Component Definitions
    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : CommandIF;
        port dataIn : StatusIF;
    }

    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : ControlIF;
        port dataIn : SignalIF;
        port configIn : DiagnosticIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part flightbus : FlightBus {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part missioncontroller : MissionController {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect flightbus.telemetryOut to missioncontroller.configIn;
        connect missioncontroller.dataIn to flightbus.dataIn;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}