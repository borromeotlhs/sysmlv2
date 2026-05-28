package arch_000011 {

    import ScalarValues::*;

    // Autonomous Rover Reference Architecture 11
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

    public requirement REQ_004 {
        doc "The autonomous rover system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ThermalIF;
        port statusOut : TelemetryIF;
        port statusOut : ThermalIF;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ThermalIF;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part navactuator : NavActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part distributioncontroller : DistributionController {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part navsubsystem : NavSubsystem {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        // Connections
        connect navsubsystem.statusOut to distributioncontroller.telemetryOut;
        connect navsubsystem.statusOut to navactuator.statusOut;
        connect distributioncontroller.telemetryOut to navactuator.statusOut;
    }

    // System Instance
    public part autonomousroversystem : AutonomousRoverSystem;

}