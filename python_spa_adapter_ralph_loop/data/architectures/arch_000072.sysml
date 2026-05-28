package arch_000072 {

    // Ground Station Reference Architecture 72
    // Domain: ground station

    // Requirements
    requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port telemetryOut;
        port sensorOut;
    }

    part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
    }

    part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
    }

    part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port dataIn;
    }

    part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
    }

    part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port cmdIn;
        port configIn;
    }

    // System Definition
    part def GroundStationSystem {
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