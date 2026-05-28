package arch_000150 {

    // Telemetry System Reference Architecture 150
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The telemetry system system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The telemetry system system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommandSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn;
        port cmdOut;
        port dataOut;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn;
        port statusOut;
        port statusOut;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port pwrOut;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port sensorOut;
        port ctrlIn;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part commandsubsystem : CommandSubsystem {
            satisfy REQ_004;
        }
        part commactuator : CommActuator {
        }
        part datacomputer : DataComputer {
            satisfy REQ_001;
        }
        part missionsensor : MissionSensor {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect commactuator.statusOut to datacomputer.pwrOut;
        connect commandsubsystem.dataOut to datacomputer.dataIn;
    }

    // System Instance
    part telemetrysystemsystem : TelemetrySystemSystem;

}