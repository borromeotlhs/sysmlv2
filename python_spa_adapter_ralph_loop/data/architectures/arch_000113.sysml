package arch_000113 {

    // Antenna Subsystem Reference Architecture 113
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn;
        port statusOut;
        port telemetryOut;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part datasensor : DataSensor {
        }
        part sensorsubsystem : SensorSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect sensorsubsystem.pwrIn to datasensor.statusOut;
        connect sensorsubsystem.pwrIn to datasensor.cmdIn;
        connect sensorsubsystem.pwrIn to datasensor.telemetryOut;
    }

    // System Instance
    part antennasubsystemsystem : AntennaSubsystemSystem;

}