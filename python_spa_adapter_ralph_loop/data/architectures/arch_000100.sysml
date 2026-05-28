package arch_000100 {

    import ScalarValues::*;

    // Imaging Payload Reference Architecture 100
    // Domain: imaging payload

    // Requirements
    public requirement REQ_001 {
        doc "The imaging payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The imaging payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The imaging payload system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The imaging payload system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : SignalIF;
        port sensorOut : TelemetryIF;
    }

    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : PowerIF;
    }

    public part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : TelemetryIF;
        port telemetryOut : DiagnosticIF;
        port statusOut : ConfigIF;
    }

    // System Definition
    public part def ImagingPayloadSystem {
        part missioncomputer : MissionComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitorassembly : MonitorAssembly {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part thermalpayload : ThermalPayload {
            satisfy REQ_004;
        }

        // Connections
        connect monitorassembly.sensorOut to thermalpayload.configIn;
        connect monitorassembly.sensorOut to missioncomputer.sensorOut;
        connect thermalpayload.telemetryOut to missioncomputer.sensorOut;
        connect missioncomputer.sensorOut to thermalpayload.configIn;
    }

    // System Instance
    public part imagingpayloadsystem : ImagingPayloadSystem;

}