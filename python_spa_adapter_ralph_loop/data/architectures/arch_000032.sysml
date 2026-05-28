package arch_000032 {

    // Ground Station Reference Architecture 32
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port telemetryOut;
        port sensorOut;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
    }

    public part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port dataIn;
    }

    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port cmdIn;
        port configIn;
    }

    // System Definition
    public part def GroundStationSystem {
        part processingcontroller : ProcessingController {
        }
        part powersensor : PowerSensor {
            satisfy REQ_001;
        }
        part comminterface : CommInterface {
        }
        part distributionassembly : DistributionAssembly {
            satisfy REQ_001;
        }
        part commandinterface : CommandInterface {
            satisfy REQ_002;
        }
        part processingbus : ProcessingBus {
            satisfy REQ_002;
        }

        // Connections
        connect processingcontroller.sensorOut to processingbus.cmdIn;
        connect commandinterface.pwrIn to processingcontroller.sensorOut;
        connect distributionassembly.dataOut to processingbus.configIn;
        connect commandinterface.pwrIn to processingbus.cmdIn;
        connect commandinterface.pwrIn to powersensor.pwrOut;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}