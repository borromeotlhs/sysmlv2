package arch_000116 {

    // Docking Mechanism Reference Architecture 116
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port dataIn;
        port configIn;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port ctrlIn;
        port configIn;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port cmdIn;
        port cmdIn;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port configIn;
        port statusOut;
    }

    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut;
        port telemetryOut;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port cmdOut;
        port pwrIn;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part monitorsensor : MonitorSensor {
        }
        part flightpayload : FlightPayload {
        }
        part processingbus : ProcessingBus {
        }
        part controlbus : ControlBus {
            satisfy REQ_002;
        }
        part powersubsystem : PowerSubsystem {
            satisfy REQ_001;
        }
        part controlassembly : ControlAssembly {
        }
        part powersensor : PowerSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect monitorsensor.configIn to flightpayload.telemetryOut;
        connect powersubsystem.pwrOut to monitorsensor.configIn;
        connect processingbus.pwrIn to controlbus.configIn;
        connect monitorsensor.dataIn to flightpayload.ctrlIn;
    }

    // System Instance
    part dockingmechanismsystem : DockingMechanismSystem;

}