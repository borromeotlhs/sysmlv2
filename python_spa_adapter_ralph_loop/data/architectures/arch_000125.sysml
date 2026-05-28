package arch_000125 {

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

    // Component Definitions
    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port pwrOut;
        port pwrIn;
    }

    public part def MonitorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port configIn;
        port configIn;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port configIn;
        port statusOut;
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
    part communicationrelaysystem : CommunicationRelaySystem;

}