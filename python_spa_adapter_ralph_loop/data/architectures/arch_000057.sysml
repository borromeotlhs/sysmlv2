package arch_000057 {

    // Propulsion Module Reference Architecture 57
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The propulsion module system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
    }

    public part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port statusOut;
        port statusOut;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part commandassembly : CommandAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part navactuator : NavActuator {
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect navactuator.statusOut to commandassembly.ctrlIn;
        connect missionassembly.telemetryOut to commandassembly.ctrlIn;
        connect navactuator.statusOut to missionassembly.statusOut;
        connect commandassembly.ctrlIn to missionassembly.statusOut;
    }

    // System Instance
    part propulsionmodulesystem : PropulsionModuleSystem;

}