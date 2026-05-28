package arch_000001 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 1
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def StatusIF;

    // Component Definitions
    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DataIF;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut : DataIF;
        port configIn : StatusIF;
        port cmdIn : CommandIF;
    }

    // System Definition
    public part def SolarArraySystem {
        part missionbus : MissionBus {
            satisfy REQ_001;
        }
        part powermodule : PowerModule {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect missionbus.dataIn to powermodule.sensorOut;
        connect powermodule.cmdIn to missionbus.dataIn;
    }

    // System Instance
    public part solararraysystem : SolarArraySystem;

}