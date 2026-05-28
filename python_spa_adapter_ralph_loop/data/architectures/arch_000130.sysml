package arch_000130 {

    // Autonomous Rover Reference Architecture 130
    // Domain: autonomous rover

    // Requirements
    public requirement REQ_001 {
        doc "The autonomous rover system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The autonomous rover system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port configIn;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part monitorassembly : MonitorAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part powermodule : PowerModule {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect monitorassembly.configIn to powermodule.cmdOut;
        connect monitorassembly.pwrIn to powermodule.cmdOut;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}