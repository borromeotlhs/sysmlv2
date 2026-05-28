package arch_000123 {

    import ScalarValues::*;

    // Radar System Reference Architecture 123
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def ProcessingInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ConfigIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : StatusIF;
        port pwrOut : SignalIF;
        port pwrIn : PowerIF;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : SignalIF;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : SignalIF;
        port cmdIn : TelemetryIF;
        port configIn : PowerIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdIn : SignalIF;
        port configIn : CommandIF;
        port pwrIn : TelemetryIF;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ConfigIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : SignalIF;
    }

    // System Definition
    public part def RadarSystemSystem {
        part processinginterface : ProcessingInterface {
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_002;
        }
        part monitorinterface : MonitorInterface {
            satisfy REQ_002;
        }
        part sensoractuator : SensorActuator {
        }
        part poweractuator : PowerActuator {
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_001;
        }
        part sensorcomputer : SensorComputer {
        }

        // Connections
        connect poweractuator.cmdIn to monitorcontroller.pwrIn;
        connect sensorcomputer.pwrIn to monitorcontroller.pwrIn;
        connect poweractuator.pwrIn to processinginterface.ctrlIn;
    }

    // System Instance
    public part radarsystemsystem : RadarSystemSystem;

}