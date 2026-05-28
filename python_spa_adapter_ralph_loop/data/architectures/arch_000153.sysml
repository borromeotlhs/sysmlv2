package arch_000153 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 153
    // Domain: instrument platform

    // Requirements
    public requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The instrument platform system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The instrument platform system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : CommandIF;
    }

    public part def ProcessingSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : PowerIF;
        port statusOut : DataIF;
        port dataOut : TelemetryIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut : ControlIF;
        port cmdIn : SignalIF;
        port telemetryOut : DataIF;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : DiagnosticIF;
        port cmdOut : ControlIF;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
        part commandprocessor : CommandProcessor {
            satisfy REQ_003;
        }
        part processingsensor : ProcessingSensor {
            satisfy REQ_001;
        }
        part poweractuator : PowerActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitoractuator : MonitorActuator {
            satisfy REQ_004;
        }

        // Connections
        connect commandprocessor.configIn to processingsensor.configIn;
        connect poweractuator.cmdOut to commandprocessor.configIn;
        connect commandprocessor.configIn to monitoractuator.pwrOut;
    }

    // System Instance
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}