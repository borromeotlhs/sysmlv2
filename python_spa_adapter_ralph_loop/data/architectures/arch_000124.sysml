package arch_000124 {

    import ScalarValues::*;

    // Thermal Control Reference Architecture 124
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
    public port def CommandIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : TelemetryIF;
    }

    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : PowerIF;
        port dataOut : DiagnosticIF;
        port pwrOut : CommandIF;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : DataIF;
        port cmdIn : PowerIF;
        port ctrlIn : StatusIF;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : TelemetryIF;
        port sensorOut : ThermalIF;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : StatusIF;
        port ctrlIn : SignalIF;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : StatusIF;
    }

    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : TelemetryIF;
    }

    // System Definition
    public part def ThermalControlSystem {
        part datapayload : DataPayload {
        }
        part commandsensor : CommandSensor {
        }
        part missionassembly : MissionAssembly {
        }
        part flightprocessor : FlightProcessor {
            satisfy REQ_001;
        }
        part controlprocessor : ControlProcessor {
            satisfy REQ_003;
        }
        part navsubsystem : NavSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part distributionsubsystem : DistributionSubsystem {
            satisfy REQ_004;
        }

        // Connections
        connect controlprocessor.ctrlIn to missionassembly.cmdIn;
        connect controlprocessor.ctrlIn to datapayload.telemetryOut;
        connect flightprocessor.sensorOut to controlprocessor.ctrlIn;
        connect missionassembly.ctrlIn to controlprocessor.telemetryOut;
        connect distributionsubsystem.pwrIn to commandsensor.telemetryOut;
    }

    // System Instance
    public part thermalcontrolsystem : ThermalControlSystem;

}