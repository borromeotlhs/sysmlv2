package arch_000041 {

    import ScalarValues::*;

    // Docking Mechanism Reference Architecture 41
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
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : ThermalIF;
        port cmdIn : TelemetryIF;
        port pwrOut : StatusIF;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ThermalIF;
    }

    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : DiagnosticIF;
        port ctrlIn : CommandIF;
    }

    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn : ConfigIF;
        port dataOut : ConfigIF;
        port pwrOut : TelemetryIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : ControlIF;
        port dataIn : TelemetryIF;
        port sensorOut : ControlIF;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part commandsensor : CommandSensor {
            satisfy REQ_003;
        }
        part monitorbus : MonitorBus {
        }
        part controlsubsystem : ControlSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part commandinterface : CommandInterface {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part datacomputer : DataComputer {
        }

        // Connections
        connect datacomputer.sensorOut to controlsubsystem.sensorOut;
        connect commandinterface.dataOut to monitorbus.statusOut;
        connect controlsubsystem.sensorOut to commandinterface.pwrOut;
        connect monitorbus.statusOut to controlsubsystem.sensorOut;
    }

    // System Instance
    public part dockingmechanismsystem : DockingMechanismSystem;

}