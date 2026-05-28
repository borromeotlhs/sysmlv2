package arch_000110 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ProcessingComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : ControlIF;
        port pwrOut : SignalIF;
    }

    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : SignalIF;
    }

    public part def SensorUnit {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : SignalIF;
    }

    public part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : ConfigIF;
        port pwrIn : ThermalIF;
    }

    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut : StatusIF;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : DataIF;
        port statusOut : ConfigIF;
        port telemetryOut : DiagnosticIF;
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
    public part antennasubsystemsystem : AntennaSubsystemSystem;

}