package arch_000076 {

    import ScalarValues::*;

    // Avionics Bay Reference Architecture 76
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The avionics bay system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : SignalIF;
        port pwrOut : TelemetryIF;
    }

    public part def NavComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DataIF;
        port telemetryOut : CommandIF;
        port dataOut : ControlIF;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part datacomputer : DataComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part navcomputer : NavComputer {
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect datacomputer.pwrOut to navcomputer.telemetryOut;
        connect navcomputer.statusOut to datacomputer.pwrOut;
        connect datacomputer.dataOut to navcomputer.statusOut;
        connect navcomputer.telemetryOut to datacomputer.dataOut;
    }

    // System Instance
    public part avionicsbaysystem : AvionicsBaySystem;

}