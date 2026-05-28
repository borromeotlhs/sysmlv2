package arch_000082 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 82
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The solar array system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : ControlIF;
        port pwrIn : CommandIF;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : ConfigIF;
        port telemetryOut : StatusIF;
        port statusOut : ThermalIF;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : TelemetryIF;
    }

    // System Definition
    public part def SolarArraySystem {
        part sensorpayload : SensorPayload {
            satisfy REQ_002;
        }
        part navprocessor : NavProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part flightpayload : FlightPayload {
            satisfy REQ_001;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect sensorpayload.dataOut to navprocessor.telemetryOut;
        connect navprocessor.dataOut to sensorpayload.dataOut;
        connect sensorpayload.dataOut to navprocessor.statusOut;
        connect flightpayload.ctrlIn to navprocessor.dataOut;
        connect navprocessor.statusOut to sensorpayload.pwrIn;
    }

    // System Instance
    public part solararraysystem : SolarArraySystem;

}