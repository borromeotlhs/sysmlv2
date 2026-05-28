package arch_000081 {

    // Avionics Bay Reference Architecture 81
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

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port cmdIn;
        port dataIn;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port configIn;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port pwrOut;
        port cmdOut;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part missionunit : MissionUnit {
            satisfy REQ_004;
        }
        part thermalinterface : ThermalInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part thermalsubsystem : ThermalSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect thermalsubsystem.cmdOut to thermalinterface.configIn;
        connect thermalsubsystem.cmdOut to missionunit.dataIn;
        connect missionunit.cmdIn to thermalsubsystem.pwrOut;
        connect missionunit.cmdOut to thermalinterface.pwrOut;
        connect thermalsubsystem.cmdOut to missionunit.cmdIn;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}