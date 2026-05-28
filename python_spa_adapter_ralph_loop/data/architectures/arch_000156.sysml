package arch_000156 {

    // Thermal Control Reference Architecture 156
    // Domain: thermal control

    // Requirements
    requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The thermal control system shall provide fault detection and recovery."
    }

    requirement REQ_004 {
        doc "The thermal control system shall maintain operational status monitoring."
    }

    // Component Definitions
    part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port cmdIn;
        port cmdOut;
    }

    part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port statusOut;
        port cmdIn;
    }

    part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    part def ThermalSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port cmdOut;
    }

    part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
    }

    part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port dataOut;
    }

    part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
    }

    // System Definition
    part def ThermalControlSystem {
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
    part thermalcontrolsystem : ThermalControlSystem;

}