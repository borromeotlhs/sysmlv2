package arch_000185 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : ControlIF;
        port cmdIn : ControlIF;
    }

    public part def MonitorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : ThermalIF;
        port configIn : TelemetryIF;
        port statusOut : DiagnosticIF;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : StatusIF;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DataIF;
        port statusOut : SignalIF;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : PowerIF;
        port sensorOut : DiagnosticIF;
        port sensorOut : CommandIF;
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
    public part sensorsuitesystem : SensorSuiteSystem;

}