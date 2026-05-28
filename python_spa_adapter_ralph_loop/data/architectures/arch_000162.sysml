package arch_000162 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 162
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
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : SignalIF;
        port pwrIn : TelemetryIF;
    }

    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : PowerIF;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : CommandIF;
        port pwrIn : SignalIF;
        port dataOut : PowerIF;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn : CommandIF;
        port cmdOut : ConfigIF;
        port pwrOut : DataIF;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : TelemetryIF;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
        part flightcontroller : FlightController {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part thermalactuator : ThermalActuator {
            satisfy REQ_002;
        }
        part powercomputer : PowerComputer {
        }
        part sensorprocessor : SensorProcessor {
            satisfy REQ_001;
        }
        part flightassembly : FlightAssembly {
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect flightassembly.statusOut to sensorprocessor.cmdOut;
        connect flightassembly.statusOut to thermalactuator.dataIn;
        connect thermalactuator.dataIn to powercomputer.dataOut;
        connect powercomputer.statusOut to sensorprocessor.ctrlIn;
    }

    // System Instance
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}