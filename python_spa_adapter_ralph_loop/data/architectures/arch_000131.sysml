package arch_000131 {

    // Autonomous Rover Reference Architecture 131
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

    requirement REQ_004 {
        doc "The autonomous rover system shall maintain operational status monitoring."
    }

    // Component Definitions
    part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port statusOut;
        port statusOut;
    }

    part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
    }

    part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    // System Definition
    part def AutonomousRoverSystem {
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
    part autonomousroversystem : AutonomousRoverSystem;

}