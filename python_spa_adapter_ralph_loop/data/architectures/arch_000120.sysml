package arch_000120 {

    import ScalarValues::*;

    // Avionics Bay Reference Architecture 120
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
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : PowerIF;
        port telemetryOut : ControlIF;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : TelemetryIF;
        port cmdIn : DataIF;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ControlIF;
        port ctrlIn : TelemetryIF;
    }

    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : ControlIF;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : PowerIF;
        port sensorOut : DataIF;
        port statusOut : DataIF;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : DataIF;
        port pwrIn : ConfigIF;
    }

    public part def ControlUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : DiagnosticIF;
        port statusOut : ThermalIF;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part navcontroller : NavController {
        }
        part navunit : NavUnit {
            satisfy REQ_002;
        }
        part monitorinterface : MonitorInterface {
            satisfy REQ_001;
        }
        part processingpayload : ProcessingPayload {
        }
        part navmodule : NavModule {
            satisfy REQ_001;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_003;
        }
        part controlunit : ControlUnit {
        }

        // Connections
        connect navmodule.sensorOut to navunit.ctrlIn;
        connect processingpayload.pwrIn to navcontroller.telemetryOut;
        connect navunit.cmdIn to controlunit.statusOut;
    }

    // System Instance
    public part avionicsbaysystem : AvionicsBaySystem;

}