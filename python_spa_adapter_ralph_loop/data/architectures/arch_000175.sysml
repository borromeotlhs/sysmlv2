package arch_000175 {

    import ScalarValues::*;

    // Autonomous Rover Reference Architecture 175
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
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : StatusIF;
    }

    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut : StatusIF;
        port dataOut : PowerIF;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : StatusIF;
    }

    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : TelemetryIF;
        port dataIn : DiagnosticIF;
        port configIn : SignalIF;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part sensorcomputer : SensorComputer {
            satisfy REQ_003;
        }
        part commandassembly : CommandAssembly {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part commsubsystem : CommSubsystem {
            satisfy REQ_001;
        }
        part commandcontroller : CommandController {
            satisfy REQ_002;
            satisfy REQ_004;
        }

        // Connections
        connect commandcontroller.dataIn to commsubsystem.pwrIn;
        connect commandassembly.cmdOut to sensorcomputer.sensorOut;
        connect commsubsystem.pwrIn to sensorcomputer.sensorOut;
    }

    // System Instance
    public part autonomousroversystem : AutonomousRoverSystem;

}