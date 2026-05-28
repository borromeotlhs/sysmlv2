package arch_000019 {

    import ScalarValues::*;

    // Life Support Reference Architecture 19
    // Domain: life support

    // Requirements
    public requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The life support system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : CommandIF;
        port dataIn : TelemetryIF;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : TelemetryIF;
        port pwrIn : PowerIF;
        port configIn : StatusIF;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DataIF;
        port ctrlIn : ControlIF;
        port statusOut : ControlIF;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DataIF;
        port dataIn : ControlIF;
    }

    // System Definition
    public part def LifeSupportSystem {
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
    public part lifesupportsystem : LifeSupportSystem;

}