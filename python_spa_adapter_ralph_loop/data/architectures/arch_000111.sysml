package arch_000111 {

    // Ground Station Reference Architecture 111
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut;
        port ctrlIn;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
    }

    // System Definition
    public part def GroundStationSystem {
        part distributionprocessor : DistributionProcessor {
        }
        part monitoractuator : MonitorActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commandassembly : CommandAssembly {
        }
        part flightsensor : FlightSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part sensorbus : SensorBus {
        }

        // Connections
        connect flightsensor.dataOut to monitoractuator.cmdIn;
        connect sensorbus.dataIn to distributionprocessor.dataIn;
        connect commandassembly.ctrlIn to monitoractuator.cmdIn;
        connect flightsensor.dataOut to commandassembly.ctrlIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}