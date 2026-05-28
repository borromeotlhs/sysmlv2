package arch_000034 {

    // Power Distribution System Reference Architecture 34
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The power distribution system system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port configIn;
        port dataIn;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port pwrOut;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port telemetryOut;
        port sensorOut;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part flightcomputer : FlightComputer {
        }
        part datasubsystem : DataSubsystem {
        }
        part monitoractuator : MonitorActuator {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part navcontroller : NavController {
            satisfy REQ_001;
        }

        // Connections
        connect navcontroller.sensorOut to flightcomputer.ctrlIn;
        connect navcontroller.telemetryOut to flightcomputer.ctrlIn;
    }

    // System Instance
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}