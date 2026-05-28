package arch_000092 {

    import ScalarValues::*;

    // Docking Mechanism Reference Architecture 92
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The docking mechanism system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The docking mechanism system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : DiagnosticIF;
        port telemetryOut : CommandIF;
    }

    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : SignalIF;
        port cmdOut : ThermalIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def MissionActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
        port dataOut : StatusIF;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : DiagnosticIF;
        port dataIn : DiagnosticIF;
        port telemetryOut : ConfigIF;
    }

    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn : ControlIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : ThermalIF;
        port statusOut : StatusIF;
        port dataIn : DataIF;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part commandprocessor : CommandProcessor {
            satisfy REQ_004;
        }
        part monitorsensor : MonitorSensor {
            satisfy REQ_001;
        }
        part missionactuator : MissionActuator {
        }
        part commandcomputer : CommandComputer {
        }
        part commandunit : CommandUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commandsensor : CommandSensor {
            satisfy REQ_002;
        }

        // Connections
        connect monitorsensor.cmdOut to commandcomputer.dataIn;
        connect commandunit.dataIn to missionactuator.dataOut;
    }

    // System Instance
    public part dockingmechanismsystem : DockingMechanismSystem;

}