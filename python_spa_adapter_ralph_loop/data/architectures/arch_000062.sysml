package arch_000062 {

    import ScalarValues::*;

    // Docking Mechanism Reference Architecture 62
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The docking mechanism system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def StatusIF;

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ConfigIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : ConfigIF;
        port statusOut : StatusIF;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part missionunit : MissionUnit {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part datacomputer : DataComputer {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect missionunit.statusOut to datacomputer.statusOut;
        connect missionunit.statusOut to datacomputer.telemetryOut;
    }

    // System Instance
    public part dockingmechanismsystem : DockingMechanismSystem;

}