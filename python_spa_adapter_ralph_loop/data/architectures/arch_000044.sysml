package arch_000044 {

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

    // Component Definitions
    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut;
        port ctrlIn;
    }

    public part def SensorAssembly {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port configIn;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port dataOut;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port pwrIn;
        port statusOut;
    }

    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port telemetryOut;
        port pwrOut;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port configIn;
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
    part instrumentplatformsystem : InstrumentPlatformSystem;

}