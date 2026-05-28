package arch_000125 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 125
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
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : TelemetryIF;
        port pwrOut : ThermalIF;
        port pwrIn : SignalIF;
    }

    public part def MonitorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : CommandIF;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : CommandIF;
        port configIn : ThermalIF;
        port configIn : DataIF;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : DataIF;
        port configIn : PowerIF;
        port statusOut : DiagnosticIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part sensorcomputer : SensorComputer {
            satisfy REQ_001;
        }
        part monitorcomputer : MonitorComputer {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part flightcomputer : FlightComputer {
        }
        part commcontroller : CommController {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect commcontroller.cmdOut to sensorcomputer.pwrOut;
        connect commcontroller.cmdOut to flightcomputer.cmdOut;
        connect flightcomputer.cmdOut to sensorcomputer.cmdOut;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}