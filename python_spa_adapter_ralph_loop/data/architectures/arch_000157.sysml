package arch_000157 {

    // Reaction Wheel Reference Architecture 157
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
    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port cmdIn;
        port cmdIn;
    }

    public part def SensorUnit {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port cmdOut;
        port telemetryOut;
    }

    public part def MissionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port configIn;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
        port dataIn;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
        port pwrOut;
        port dataOut;
    }

    public part def ProcessingActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part controlbus : ControlBus {
            satisfy REQ_004;
        }
        part sensorunit : SensorUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part missionpayload : MissionPayload {
        }
        part commpayload : CommPayload {
            satisfy REQ_004;
        }
        part sensoractuator : SensorActuator {
        }
        part processingactuator : ProcessingActuator {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect controlbus.cmdIn to sensorunit.cmdOut;
        connect missionpayload.cmdOut to processingactuator.configIn;
        connect sensorunit.telemetryOut to sensoractuator.dataOut;
        connect sensoractuator.dataOut to processingactuator.configIn;
        connect commpayload.dataIn to sensorunit.pwrOut;
    }

    // System Instance
    part reactionwheelsystem : ReactionWheelSystem;

}