package arch_000081 {

    // Solar Array Reference Architecture 81
    // Domain: solar array

    // Requirements
    requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut;
        port configIn;
        port cmdIn;
    }

    // System Definition
    part def SolarArraySystem {
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
    part solararraysystem : SolarArraySystem;

}