package arch_000031 {

    // Autonomous Rover Reference Architecture 31
    // Domain: autonomous rover

    // Requirements
    public requirement REQ_001 {
        doc "The autonomous rover system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The autonomous rover system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port configIn;
        port cmdIn;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part thermalunit : ThermalUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part flightinterface : FlightInterface {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect flightinterface.statusOut to thermalunit.configIn;
        connect thermalunit.configIn to flightinterface.configIn;
        connect thermalunit.configIn to flightinterface.cmdIn;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}