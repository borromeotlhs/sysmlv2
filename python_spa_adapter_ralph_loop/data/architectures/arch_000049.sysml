package arch_000049 {

    // Reaction Wheel Reference Architecture 49
    // Domain: reaction wheel

    // Requirements
    requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port cmdIn;
        port dataOut;
    }

    part def DistributionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port dataOut;
    }

    part def ProcessingModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port cmdOut;
    }

    // System Definition
    part def ReactionWheelSystem {
        part distributionsubsystem : DistributionSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part distributioninterface : DistributionInterface {
        }
        part processingmodule : ProcessingModule {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part powerprocessor : PowerProcessor {
        }

        // Connections
        connect powerprocessor.pwrOut to processingmodule.telemetryOut;
        connect distributionsubsystem.cmdIn to distributioninterface.dataOut;
        connect distributioninterface.dataOut to distributionsubsystem.cmdOut;
        connect distributionsubsystem.cmdIn to powerprocessor.pwrOut;
    }

    // System Instance
    part reactionwheelsystem : ReactionWheelSystem;

}