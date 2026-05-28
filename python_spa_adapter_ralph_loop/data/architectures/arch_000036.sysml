package arch_000036 {

    import ScalarValues::*;

    // Thermal Control Reference Architecture 36
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The thermal control system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The thermal control system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : TelemetryIF;
        port cmdIn : PowerIF;
        port cmdOut : ThermalIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : ControlIF;
        port statusOut : DiagnosticIF;
        port cmdIn : DiagnosticIF;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : TelemetryIF;
    }

    public part def ThermalSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : TelemetryIF;
        port cmdOut : DiagnosticIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : ControlIF;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : SignalIF;
        port dataOut : DataIF;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : TelemetryIF;
    }

    // System Definition
    public part def ThermalControlSystem {
        part distributioncomputer : DistributionComputer {
            satisfy REQ_001;
        }
        part flightinterface : FlightInterface {
            satisfy REQ_004;
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part thermalsensor : ThermalSensor {
        }
        part distributionbus : DistributionBus {
            satisfy REQ_003;
        }
        part monitorprocessor : MonitorProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part missionprocessor : MissionProcessor {
        }

        // Connections
        connect thermalsensor.cmdOut to distributioncomputer.cmdIn;
        connect missionprocessor.dataIn to flightinterface.statusOut;
        connect flightinterface.pwrOut to distributionbus.sensorOut;
        connect monitorprocessor.dataOut to thermalsensor.pwrOut;
        connect distributioncomputer.cmdIn to thermalsensor.pwrOut;
    }

    // System Instance
    public part thermalcontrolsystem : ThermalControlSystem;

}