package arch_000078 {

    // Ground Station Reference Architecture 78
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port statusOut;
        port pwrOut;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port cmdOut;
        port cmdIn;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port ctrlIn;
        port sensorOut;
    }

    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port pwrIn;
        port cmdIn;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
    }

    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port dataIn;
    }

    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port ctrlIn;
        port telemetryOut;
    }

    // System Definition
    public part def GroundStationSystem {
        part powerbus : PowerBus {
            satisfy REQ_002;
        }
        part distributionsensor : DistributionSensor {
        }
        part distributionprocessor : DistributionProcessor {
        }
        part monitorassembly : MonitorAssembly {
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_001;
        }
        part dataassembly : DataAssembly {
        }
        part databus : DataBus {
            satisfy REQ_001;
        }

        // Connections
        connect databus.dataIn to monitorassembly.statusOut;
        connect databus.ctrlIn to distributionsensor.pwrIn;
        connect databus.ctrlIn to dataassembly.configIn;
        connect powerbus.pwrOut to distributionprocessor.ctrlIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}