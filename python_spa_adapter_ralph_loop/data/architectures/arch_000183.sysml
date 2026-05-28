package arch_000183 {

    // Communication Relay Reference Architecture 183
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The communication relay system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The communication relay system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
        port dataOut;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port dataIn;
        port cmdIn;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut;
    }

    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut;
        port statusOut;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part powerbus : PowerBus {
            satisfy REQ_002;
        }
        part powersensor : PowerSensor {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part sensorinterface : SensorInterface {
        }
        part commactuator : CommActuator {
            satisfy REQ_004;
        }
        part commbus : CommBus {
            satisfy REQ_004;
        }

        // Connections
        connect sensorinterface.cmdIn to powersensor.dataOut;
        connect sensorinterface.pwrIn to commbus.telemetryOut;
        connect commbus.statusOut to powersensor.dataIn;
    }

    // System Instance
    part communicationrelaysystem : CommunicationRelaySystem;

}