package arch_000082 {

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

    // Component Definitions
    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
        port pwrIn;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port telemetryOut;
        port statusOut;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
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
    part solararraysystem : SolarArraySystem;

}