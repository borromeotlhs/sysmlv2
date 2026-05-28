package arch_000150 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn : ThermalIF;
        port cmdOut : TelemetryIF;
        port dataOut : SignalIF;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn : CommandIF;
        port statusOut : DiagnosticIF;
        port statusOut : DiagnosticIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : DataIF;
        port pwrOut : PowerIF;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : CommandIF;
        port sensorOut : StatusIF;
        port ctrlIn : TelemetryIF;
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
    public part telemetrysystemsystem : TelemetrySystemSystem;

}