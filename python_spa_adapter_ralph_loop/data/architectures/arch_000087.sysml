package arch_000087 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 87
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The communication relay system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DataIF;
        port telemetryOut : PowerIF;
        port cmdIn : TelemetryIF;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : CommandIF;
        port cmdOut : DataIF;
        port cmdIn : PowerIF;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : DataIF;
        port configIn : ThermalIF;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : StatusIF;
        port ctrlIn : StatusIF;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : CommandIF;
        port statusOut : DataIF;
    }

    public part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : DiagnosticIF;
        port cmdOut : DiagnosticIF;
        port cmdIn : DataIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part sensorcomputer : SensorComputer {
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_003;
        }
        part datainterface : DataInterface {
        }
        part monitormodule : MonitorModule {
            satisfy REQ_001;
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_002;
        }
        part flightmodule : FlightModule {
        }

        // Connections
        connect flightmodule.cmdIn to monitormodule.statusOut;
        connect monitorcontroller.cmdOut to flightmodule.cmdIn;
        connect monitorcontroller.cmdOut to monitormodule.ctrlIn;
        connect flightmodule.cmdIn to datainterface.configIn;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}