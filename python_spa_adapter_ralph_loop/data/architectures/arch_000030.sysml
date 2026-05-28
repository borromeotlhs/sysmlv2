package arch_000030 {

    // Antenna Subsystem Reference Architecture 30
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port pwrOut;
        port telemetryOut;
    }

    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port configIn;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
        port telemetryOut;
        port ctrlIn;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port telemetryOut;
        port pwrOut;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part thermalcontroller : ThermalController {
            satisfy REQ_001;
        }
        part commcontroller : CommController {
        }
        part datasubsystem : DataSubsystem {
        }
        part controlsubsystem : ControlSubsystem {
            satisfy REQ_002;
        }
        part sensorcontroller : SensorController {
            satisfy REQ_001;
        }
        part communit : CommUnit {
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_002;
        }

        // Connections
        connect sensorcontroller.configIn to commcontroller.sensorOut;
        connect sensorcontroller.configIn to communit.ctrlIn;
        connect processingassembly.telemetryOut to datasubsystem.telemetryOut;
    }

    // System Instance
    part antennasubsystemsystem : AntennaSubsystemSystem;

}