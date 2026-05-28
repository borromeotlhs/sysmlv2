package arch_000122 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 122
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
    public port def ConfigIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def StatusIF;

    // Component Definitions
    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ControlIF;
        port statusOut : StatusIF;
    }

    public part def ProcessingActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ConfigIF;
        port dataOut : PowerIF;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
        part datasubsystem : DataSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part processingactuator : ProcessingActuator {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect processingactuator.dataOut to datasubsystem.statusOut;
        connect processingactuator.dataOut to datasubsystem.telemetryOut;
        connect processingactuator.statusOut to datasubsystem.telemetryOut;
    }

    // System Instance
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}