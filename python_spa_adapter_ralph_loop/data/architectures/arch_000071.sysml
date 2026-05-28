package arch_000071 {

    import ScalarValues::*;

    // Antenna Subsystem Reference Architecture 71
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The antenna subsystem system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;

    // Component Definitions
    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : DataIF;
        port cmdOut : ControlIF;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : PowerIF;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part distributioncomputer : DistributionComputer {
            satisfy REQ_002;
        }
        part powercomputer : PowerComputer {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect powercomputer.statusOut to distributioncomputer.pwrIn;
        connect distributioncomputer.cmdOut to powercomputer.statusOut;
    }

    // System Instance
    public part antennasubsystemsystem : AntennaSubsystemSystem;

}