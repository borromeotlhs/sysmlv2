package arch_000044 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 44
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
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut : ThermalIF;
        port ctrlIn : SignalIF;
    }

    public part def SensorAssembly {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : DiagnosticIF;
        port configIn : CommandIF;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ControlIF;
        port dataOut : CommandIF;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : TelemetryIF;
        port pwrIn : PowerIF;
        port statusOut : ConfigIF;
    }

    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : DataIF;
        port telemetryOut : SignalIF;
        port pwrOut : DiagnosticIF;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : PowerIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : TelemetryIF;
        port configIn : ControlIF;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
        part commsubsystem : CommSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part sensorassembly : SensorAssembly {
        }
        part flightsubsystem : FlightSubsystem {
        }
        part monitorcontroller : MonitorController {
        }
        part commandprocessor : CommandProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part navassembly : NavAssembly {
            satisfy REQ_001;
        }
        part datacomputer : DataComputer {
        }

        // Connections
        connect commandprocessor.pwrOut to monitorcontroller.statusOut;
        connect navassembly.dataOut to monitorcontroller.statusOut;
        connect datacomputer.dataIn to sensorassembly.configIn;
        connect commandprocessor.telemetryOut to navassembly.dataOut;
        connect datacomputer.dataIn to navassembly.dataOut;
    }

    // System Instance
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}