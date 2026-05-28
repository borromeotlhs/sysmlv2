package arch_000182 {

    // Autonomous Rover Reference Architecture 182
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

    // Component Definitions
    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
        port sensorOut;
    }

    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut;
        port telemetryOut;
        port statusOut;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part commactuator : CommActuator {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commandmodule : CommandModule {
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect commandmodule.telemetryOut to commactuator.pwrIn;
        connect commandmodule.telemetryOut to commactuator.sensorOut;
        connect commactuator.sensorOut to commandmodule.statusOut;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}