package arch_000160 {

    // Guidance Navigation Reference Architecture 160
    // Domain: guidance navigation

    // Requirements
    public requirement REQ_001 {
        doc "The guidance navigation system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The guidance navigation system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The guidance navigation system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The guidance navigation system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port configIn;
        port telemetryOut;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port dataOut;
        port cmdOut;
    }

    public part def CommandBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut;
        port dataIn;
        port sensorOut;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
    }

    // System Definition
    public part def GuidanceNavigationSystem {
        part missionunit : MissionUnit {
        }
        part sensoractuator : SensorActuator {
            satisfy REQ_002;
        }
        part commandbus : CommandBus {
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part commpayload : CommPayload {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        // Connections
        connect commandbus.sensorOut to sensoractuator.cmdOut;
        connect missionunit.dataOut to commandbus.sensorOut;
        connect sensoractuator.dataOut to commandbus.pwrOut;
        connect missionunit.configIn to commandbus.dataIn;
    }

    // System Instance
    part guidancenavigationsystem : GuidanceNavigationSystem;

}