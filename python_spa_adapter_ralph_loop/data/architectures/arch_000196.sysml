package arch_000196 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;

    // Component Definitions
    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DiagnosticIF;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : PowerIF;
        port dataOut : DataIF;
        port dataIn : StatusIF;
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
    public part attitudecontrolsystem : AttitudeControlSystem;

}