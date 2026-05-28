package arch_000106 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : ThermalIF;
        port sensorOut : ThermalIF;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : PowerIF;
        port sensorOut : ConfigIF;
        port statusOut : DataIF;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : ControlIF;
        port telemetryOut : TelemetryIF;
        port telemetryOut : StatusIF;
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
    public part lunarhabitatsystem : LunarHabitatSystem;

}