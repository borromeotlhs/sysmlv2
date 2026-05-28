package arch_000124 {

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

    // Component Definitions
    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port dataOut;
        port pwrOut;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port cmdIn;
        port ctrlIn;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port sensorOut;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port ctrlIn;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
    }

    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
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
    part thermalcontrolsystem : ThermalControlSystem;

}