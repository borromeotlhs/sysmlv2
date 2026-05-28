package arch_000081 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : DataIF;
        port cmdIn : CommandIF;
        port dataIn : PowerIF;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : TelemetryIF;
        port configIn : SignalIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ControlIF;
        port pwrOut : PowerIF;
        port cmdOut : StatusIF;
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
    public part avionicsbaysystem : AvionicsBaySystem;

}