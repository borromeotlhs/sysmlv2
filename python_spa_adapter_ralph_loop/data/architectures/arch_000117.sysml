package arch_000117 {

    // Reaction Wheel Reference Architecture 117
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

    // Component Definitions
    public part def SensorUnit {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port sensorOut;
        port dataOut;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port cmdOut;
        port pwrIn;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part sensorunit : SensorUnit {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part controlbus : ControlBus {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect controlbus.cmdOut to sensorunit.sensorOut;
        connect controlbus.pwrIn to sensorunit.dataOut;
        connect sensorunit.dataOut to controlbus.pwrOut;
        connect controlbus.pwrOut to sensorunit.sensorOut;
    }

    // System Instance
    part reactionwheelsystem : ReactionWheelSystem;

}