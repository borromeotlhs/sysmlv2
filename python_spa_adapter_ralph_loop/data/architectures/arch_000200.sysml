package arch_000200 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 200
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : SignalIF;
        port telemetryOut : DiagnosticIF;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : TelemetryIF;
        port dataOut : ControlIF;
        port pwrIn : ThermalIF;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : StatusIF;
        port dataIn : TelemetryIF;
        port dataOut : StatusIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : TelemetryIF;
        port cmdOut : TelemetryIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part missionsensor : MissionSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part monitoractuator : MonitorActuator {
            satisfy REQ_001;
        }
        part flightbus : FlightBus {
        }
        part processingbus : ProcessingBus {
        }

        // Connections
        connect flightbus.dataOut to monitoractuator.dataOut;
        connect monitoractuator.dataOut to processingbus.cmdOut;
        connect missionsensor.telemetryOut to monitoractuator.pwrIn;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}