package arch_000154 {

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

    // Component Definitions
    public part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port cmdOut;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port telemetryOut;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port ctrlIn;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port configIn;
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
    part lunarhabitatsystem : LunarHabitatSystem;

}