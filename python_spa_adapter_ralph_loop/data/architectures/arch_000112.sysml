package arch_000112 {

    // Power Distribution System Reference Architecture 112
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The power distribution system system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def CommComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
    }

    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part commcomputer : CommComputer {
            satisfy REQ_002;
        }
        part powersubsystem : PowerSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect powersubsystem.cmdOut to commcomputer.telemetryOut;
    }

    // System Instance
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}