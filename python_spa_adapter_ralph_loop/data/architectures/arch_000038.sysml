package arch_000038 {

    import ScalarValues::*;

    // Autonomous Rover Reference Architecture 38
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

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : ThermalIF;
        port configIn : StatusIF;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : CommandIF;
        port ctrlIn : ConfigIF;
        port pwrIn : SignalIF;
    }

    // System Definition
    public part def AutonomousRoverSystem {
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
    public part autonomousroversystem : AutonomousRoverSystem;

}