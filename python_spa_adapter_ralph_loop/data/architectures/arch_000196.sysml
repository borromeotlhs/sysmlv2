package arch_000196 {

    // Attitude Control Reference Architecture 196
    // Domain: attitude control

    // Requirements
    public requirement REQ_001 {
        doc "The attitude control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The attitude control system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The attitude control system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The attitude control system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port dataOut;
        port dataIn;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part processingbus : ProcessingBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part sensoractuator : SensorActuator {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect processingbus.dataOut to sensoractuator.telemetryOut;
        connect processingbus.dataOut to sensoractuator.dataIn;
    }

    // System Instance
    part attitudecontrolsystem : AttitudeControlSystem;

}