package arch_000094 {

    // Fuel Cell Reference Architecture 94
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port cmdOut;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port cmdOut;
    }

    public part def CommAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
        port cmdOut;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrIn;
        port cmdIn;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port cmdIn;
        port telemetryOut;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port configIn;
    }

    // System Definition
    public part def FuelCellSystem {
        part commandcontroller : CommandController {
        }
        part datasensor : DataSensor {
        }
        part commassembly : CommAssembly {
        }
        part distributionsensor : DistributionSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part controlbus : ControlBus {
        }
        part monitorbus : MonitorBus {
            satisfy REQ_002;
        }
        part missionprocessor : MissionProcessor {
            satisfy REQ_001;
        }

        // Connections
        connect controlbus.cmdIn to datasensor.configIn;
        connect commandcontroller.telemetryOut to commassembly.cmdOut;
        connect monitorbus.ctrlIn to commandcontroller.telemetryOut;
    }

    // System Instance
    part fuelcellsystem : FuelCellSystem;

}