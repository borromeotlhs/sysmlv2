package arch_000041 {

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

    // Component Definitions
    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port cmdIn;
        port pwrOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port ctrlIn;
    }

    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn;
        port dataOut;
        port pwrOut;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port dataIn;
        port sensorOut;
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
    part dockingmechanismsystem : DockingMechanismSystem;

}