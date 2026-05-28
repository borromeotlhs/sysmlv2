package arch_000106 {

    // Lunar Habitat Reference Architecture 106
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The lunar habitat system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port sensorOut;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port sensorOut;
        port statusOut;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port telemetryOut;
        port telemetryOut;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part sensorcontroller : SensorController {
            satisfy REQ_001;
        }
        part flightbus : FlightBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part datasensor : DataSensor {
            satisfy REQ_003;
        }

        // Connections
        connect flightbus.telemetryOut to datasensor.telemetryOut;
        connect datasensor.telemetryOut to flightbus.statusOut;
    }

    // System Instance
    part lunarhabitatsystem : LunarHabitatSystem;

}