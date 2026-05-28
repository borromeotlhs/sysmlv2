package arch_000022 {

    // Sensor Suite Reference Architecture 22
    // Domain: sensor suite

    // Requirements
    public requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The sensor suite system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
        port telemetryOut;
        port ctrlIn;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port pwrIn;
        port ctrlIn;
    }

    // System Definition
    public part def SensorSuiteSystem {
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