package arch_000182 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : ControlIF;
        port sensorOut : TelemetryIF;
    }

    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut : CommandIF;
        port telemetryOut : StatusIF;
        port statusOut : ThermalIF;
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
    public part autonomousroversystem : AutonomousRoverSystem;

}