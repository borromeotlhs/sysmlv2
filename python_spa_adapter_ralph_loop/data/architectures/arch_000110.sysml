package arch_000110 {

    // Antenna Subsystem Reference Architecture 110
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The antenna subsystem system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The antenna subsystem system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def ProcessingComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port pwrOut;
    }

    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
    }

    public part def SensorUnit {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn;
        port pwrIn;
    }

    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port statusOut;
        port telemetryOut;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part processingcomputer : ProcessingComputer {
        }
        part missionmodule : MissionModule {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part sensorunit : SensorUnit {
        }
        part thermalpayload : ThermalPayload {
        }
        part commbus : CommBus {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part commandcomputer : CommandComputer {
            satisfy REQ_004;
        }

        // Connections
        connect commbus.pwrOut to sensorunit.telemetryOut;
        connect missionmodule.sensorOut to commbus.pwrOut;
        connect commandcomputer.telemetryOut to thermalpayload.pwrIn;
    }

    // System Instance
    part antennasubsystemsystem : AntennaSubsystemSystem;

}