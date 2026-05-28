package arch_000175 {

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

    // Component Definitions
    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
        port dataOut;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
    }

    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port dataIn;
        port configIn;
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
    part autonomousroversystem : AutonomousRoverSystem;

}