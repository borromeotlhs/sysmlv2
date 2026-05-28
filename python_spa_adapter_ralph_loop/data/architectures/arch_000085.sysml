package arch_000085 {

    import ScalarValues::*;

    // Imaging Payload Reference Architecture 85
    // Domain: imaging payload

    // Requirements
    public requirement REQ_001 {
        doc "The imaging payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The imaging payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The imaging payload system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The imaging payload system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MissionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : ThermalIF;
        port pwrIn : PowerIF;
        port pwrIn : SignalIF;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : SignalIF;
    }

    // System Definition
    public part def ImagingPayloadSystem {
        part missionsubsystem : MissionSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part commandcomputer : CommandComputer {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        // Connections
        connect commandcomputer.cmdIn to missionsubsystem.cmdIn;
        connect missionsubsystem.pwrIn to commandcomputer.cmdIn;
    }

    // System Instance
    public part imagingpayloadsystem : ImagingPayloadSystem;

}