package arch_000185 {

    // Sensor Suite Reference Architecture 185
    // Domain: sensor suite

    // Requirements
    public requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The sensor suite system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ControlInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port cmdIn;
    }

    public part def MonitorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port configIn;
        port statusOut;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port statusOut;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port sensorOut;
        port sensorOut;
    }

    // System Definition
    public part def SensorSuiteSystem {
        part controlinterface : ControlInterface {
        }
        part monitorpayload : MonitorPayload {
            satisfy REQ_001;
        }
        part sensorsubsystem : SensorSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitormodule : MonitorModule {
            satisfy REQ_002;
        }
        part missioninterface : MissionInterface {
        }

        // Connections
        connect monitormodule.statusOut to controlinterface.cmdIn;
        connect monitormodule.statusOut to monitorpayload.ctrlIn;
        connect missioninterface.sensorOut to controlinterface.cmdIn;
    }

    // System Instance
    part sensorsuitesystem : SensorSuiteSystem;

}