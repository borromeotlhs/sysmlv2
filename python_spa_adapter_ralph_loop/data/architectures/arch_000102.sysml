package arch_000102 {

    // Sensor Suite Reference Architecture 102
    // Domain: sensor suite

    // Requirements
    requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The sensor suite system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
    }

    part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
        port telemetryOut;
        port ctrlIn;
    }

    part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
    }

    part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port pwrIn;
        port ctrlIn;
    }

    // System Definition
    part def SensorSuiteSystem {
        part commprocessor : CommProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part datasensor : DataSensor {
        }
        part commactuator : CommActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitorprocessor : MonitorProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect datasensor.statusOut to monitorprocessor.ctrlIn;
        connect commactuator.dataOut to monitorprocessor.pwrIn;
        connect monitorprocessor.ctrlIn to commactuator.dataOut;
    }

    // System Instance
    part sensorsuitesystem : SensorSuiteSystem;

}