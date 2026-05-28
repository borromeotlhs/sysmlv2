package arch_000070 {

    // Antenna Subsystem Reference Architecture 70
    // Domain: antenna subsystem

    // Requirements
    requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
    }

    part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port pwrOut;
        port telemetryOut;
    }

    part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port configIn;
    }

    part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
        port telemetryOut;
        port ctrlIn;
    }

    part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port telemetryOut;
        port pwrOut;
    }

    // System Definition
    part def AntennaSubsystemSystem {
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