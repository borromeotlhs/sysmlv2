package arch_000117 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def PowerIF;

    // Component Definitions
    public part def SensorUnit {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : ConfigIF;
        port sensorOut : CommandIF;
        port dataOut : DiagnosticIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : ControlIF;
        port cmdOut : PowerIF;
        port pwrIn : CommandIF;
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
    public part reactionwheelsystem : ReactionWheelSystem;

}