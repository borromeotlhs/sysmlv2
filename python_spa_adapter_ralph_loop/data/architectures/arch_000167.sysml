package arch_000167 {

    // Solar Array Reference Architecture 167
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
    public part def MonitorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port pwrIn;
        port sensorOut;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port dataOut;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port cmdOut;
        port dataOut;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port telemetryOut;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
    }

    // System Definition
    public part def SolarArraySystem {
        part monitorcomputer : MonitorComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part thermalsubsystem : ThermalSubsystem {
        }
        part communit : CommUnit {
        }
        part flightinterface : FlightInterface {
            satisfy REQ_004;
        }
        part sensorpayload : SensorPayload {
            satisfy REQ_002;
        }
        part navassembly : NavAssembly {
        }
        part sensorcomputer : SensorComputer {
            satisfy REQ_001;
        }

        // Connections
        connect thermalsubsystem.cmdIn to monitorcomputer.pwrIn;
        connect thermalsubsystem.cmdIn to communit.configIn;
        connect communit.configIn to flightinterface.dataOut;
        connect monitorcomputer.pwrIn to sensorcomputer.configIn;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}