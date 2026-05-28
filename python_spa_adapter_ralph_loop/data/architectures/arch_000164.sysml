package arch_000164 {

    // Avionics Bay Reference Architecture 164
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
    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port sensorOut;
        port statusOut;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port ctrlIn;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part missionmodule : MissionModule {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part dataactuator : DataActuator {
            satisfy REQ_001;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect missionmodule.dataOut to dataactuator.cmdIn;
        connect dataactuator.cmdIn to missionmodule.sensorOut;
        connect missionmodule.statusOut to dataactuator.ctrlIn;
        connect dataactuator.ctrlIn to missionmodule.sensorOut;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}