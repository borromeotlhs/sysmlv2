package arch_000179 {

    // Life Support Reference Architecture 179
    // Domain: life support

    // Requirements
    requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The life support system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port dataIn;
    }

    part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrIn;
        port configIn;
    }

    part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
        port statusOut;
    }

    part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port dataIn;
    }

    // System Definition
    part def LifeSupportSystem {
        part missioncontroller : MissionController {
            satisfy REQ_003;
        }
        part datainterface : DataInterface {
            satisfy REQ_001;
        }
        part controlactuator : ControlActuator {
            satisfy REQ_002;
        }
        part missioninterface : MissionInterface {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect controlactuator.statusOut to datainterface.configIn;
        connect controlactuator.ctrlIn to missioninterface.telemetryOut;
        connect controlactuator.statusOut to missioncontroller.dataIn;
        connect datainterface.configIn to controlactuator.ctrlIn;
        connect missioncontroller.configIn to missioninterface.telemetryOut;
    }

    // System Instance
    part lifesupportsystem : LifeSupportSystem;

}