package arch_000148 {

    // Reaction Wheel Reference Architecture 148
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port pwrIn;
    }

    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn;
    }

    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
        port sensorOut;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part commmodule : CommModule {
        }
        part commandcontroller : CommandController {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part commandmodule : CommandModule {
            satisfy REQ_002;
        }

        // Connections
        connect commmodule.pwrIn to commandcontroller.ctrlIn;
        connect commandcontroller.ctrlIn to commandmodule.cmdOut;
        connect commandcontroller.ctrlIn to commmodule.ctrlIn;
        connect commandmodule.sensorOut to commmodule.ctrlIn;
    }

    // System Instance
    part reactionwheelsystem : ReactionWheelSystem;

}