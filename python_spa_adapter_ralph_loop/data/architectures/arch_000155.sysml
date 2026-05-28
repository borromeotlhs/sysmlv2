package arch_000155 {

    import ScalarValues::*;

    // Avionics Bay Reference Architecture 155
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : ConfigIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut : StatusIF;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : TelemetryIF;
        port telemetryOut : DiagnosticIF;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part sensorsubsystem : SensorSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part poweractuator : PowerActuator {
            satisfy REQ_001;
        }
        part missionsensor : MissionSensor {
            satisfy REQ_003;
        }

        // Connections
        connect sensorsubsystem.cmdIn to missionsensor.telemetryOut;
        connect poweractuator.sensorOut to missionsensor.telemetryOut;
        connect poweractuator.sensorOut to sensorsubsystem.cmdIn;
    }

    // System Instance
    public part avionicsbaysystem : AvionicsBaySystem;

}