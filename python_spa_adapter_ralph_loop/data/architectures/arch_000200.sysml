package arch_000200 {

    // Communication Relay Reference Architecture 200
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port telemetryOut;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port dataOut;
        port pwrIn;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port dataIn;
        port dataOut;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdOut;
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
    part communicationrelaysystem : CommunicationRelaySystem;

}