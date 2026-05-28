package arch_000056 {

    // Reaction Wheel Reference Architecture 56
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The reaction wheel system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The reaction wheel system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
    }

    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port pwrOut;
        port ctrlIn;
    }

    public part def CommComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port sensorOut;
    }

    public part def ProcessingModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port statusOut;
        port cmdOut;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port dataIn;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port telemetryOut;
        port pwrOut;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part datapayload : DataPayload {
        }
        part controlsubsystem : ControlSubsystem {
            satisfy REQ_001;
        }
        part commcomputer : CommComputer {
        }
        part processingmodule : ProcessingModule {
            satisfy REQ_001;
            satisfy REQ_004;
        }
        part dataunit : DataUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part distributionbus : DistributionBus {
            satisfy REQ_002;
        }

        // Connections
        connect commcomputer.telemetryOut to controlsubsystem.dataIn;
        connect commcomputer.sensorOut to distributionbus.configIn;
        connect processingmodule.statusOut to dataunit.ctrlIn;
    }

    // System Instance
    part reactionwheelsystem : ReactionWheelSystem;

}