package arch_000191 {

    // Command Data Handling Reference Architecture 191
    // Domain: command data handling

    // Requirements
    public requirement REQ_001 {
        doc "The command data handling system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The command data handling system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The command data handling system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The command data handling system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def FlightUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port pwrOut;
        port telemetryOut;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port dataIn;
        port statusOut;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
    }

    public part def SensorModule {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port statusOut;
        port pwrOut;
    }

    // System Definition
    public part def CommandDataHandlingSystem {
        part flightunit : FlightUnit {
            satisfy REQ_002;
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part processingprocessor : ProcessingProcessor {
            satisfy REQ_001;
        }
        part sensormodule : SensorModule {
            satisfy REQ_004;
        }
        part flightinterface : FlightInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect flightunit.telemetryOut to monitorsubsystem.dataIn;
        connect processingprocessor.configIn to monitorsubsystem.dataIn;
        connect flightunit.telemetryOut to flightinterface.cmdOut;
        connect flightinterface.statusOut to sensormodule.pwrIn;
    }

    // System Instance
    part commanddatahandlingsystem : CommandDataHandlingSystem;

}