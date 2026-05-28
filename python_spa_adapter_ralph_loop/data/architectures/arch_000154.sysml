package arch_000154 {

    import ScalarValues::*;

    // Lunar Habitat Reference Architecture 154
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The lunar habitat system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The lunar habitat system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : PowerIF;
        port cmdOut : SignalIF;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : SignalIF;
        port telemetryOut : DiagnosticIF;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : DataIF;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : ThermalIF;
        port ctrlIn : TelemetryIF;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : SignalIF;
        port configIn : DiagnosticIF;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part powerprocessor : PowerProcessor {
            satisfy REQ_002;
        }
        part datasubsystem : DataSubsystem {
            satisfy REQ_003;
        }
        part flightcomputer : FlightComputer {
            satisfy REQ_001;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_002;
        }
        part commsubsystem : CommSubsystem {
        }

        // Connections
        connect powerprocessor.cmdOut to dataprocessor.ctrlIn;
        connect datasubsystem.statusOut to dataprocessor.ctrlIn;
        connect powerprocessor.telemetryOut to commsubsystem.configIn;
        connect commsubsystem.ctrlIn to datasubsystem.telemetryOut;
        connect datasubsystem.statusOut to commsubsystem.ctrlIn;
    }

    // System Instance
    public part lunarhabitatsystem : LunarHabitatSystem;

}