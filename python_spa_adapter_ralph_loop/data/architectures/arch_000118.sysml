package arch_000118 {

    // Autonomous Rover Reference Architecture 118
    // Domain: autonomous rover

    // Requirements
    requirement REQ_001 {
        doc "The autonomous rover system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The autonomous rover system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port configIn;
    }

    part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port ctrlIn;
        port pwrIn;
    }

    // System Definition
    part def AutonomousRoverSystem {
        part flightcomputer : FlightComputer {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitoractuator : MonitorActuator {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect flightcomputer.configIn to monitoractuator.ctrlIn;
        connect monitoractuator.ctrlIn to flightcomputer.telemetryOut;
        connect flightcomputer.configIn to monitoractuator.telemetryOut;
        connect flightcomputer.telemetryOut to monitoractuator.telemetryOut;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}