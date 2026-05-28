package arch_000024 {

    import ScalarValues::*;

    // Robotic Arm Reference Architecture 24
    // Domain: robotic arm

    // Requirements
    public requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : DataIF;
        port dataIn : CommandIF;
        port cmdIn : SignalIF;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : DataIF;
        port dataOut : ConfigIF;
    }

    public part def MonitorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : TelemetryIF;
    }

    public part def ProcessingUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ConfigIF;
        port statusOut : DiagnosticIF;
    }

    // System Definition
    public part def RoboticArmSystem {
        part controlmodule : ControlModule {
            satisfy REQ_003;
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_003;
        }
        part monitorpayload : MonitorPayload {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part processingunit : ProcessingUnit {
        }

        // Connections
        connect processingunit.telemetryOut to controlmodule.dataIn;
        connect processingunit.telemetryOut to monitorcontroller.dataOut;
        connect monitorpayload.statusOut to monitorcontroller.cmdOut;
    }

    // System Instance
    public part roboticarmsystem : RoboticArmSystem;

}