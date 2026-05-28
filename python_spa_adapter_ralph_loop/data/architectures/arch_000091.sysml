package arch_000091 {

    // Autonomous Rover Reference Architecture 91
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
    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrIn;
        port sensorOut;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part monitorassembly : MonitorAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part flightbus : FlightBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect flightbus.statusOut to monitorassembly.pwrIn;
        connect flightbus.statusOut to monitorassembly.sensorOut;
        connect monitorassembly.telemetryOut to flightbus.statusOut;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}