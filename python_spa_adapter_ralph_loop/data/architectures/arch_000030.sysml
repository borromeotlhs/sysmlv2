package arch_000030 {

    import ScalarValues::*;

    // Antenna Subsystem Reference Architecture 30
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : PowerIF;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : DataIF;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : ThermalIF;
        port pwrOut : ControlIF;
        port telemetryOut : PowerIF;
    }

    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : PowerIF;
    }

    public part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : PowerIF;
        port configIn : PowerIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut : PowerIF;
        port telemetryOut : TelemetryIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DiagnosticIF;
        port telemetryOut : DiagnosticIF;
        port pwrOut : ControlIF;
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
    public part antennasubsystemsystem : AntennaSubsystemSystem;

}