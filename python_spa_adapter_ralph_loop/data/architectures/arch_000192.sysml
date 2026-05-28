package arch_000192 {

    // Sensor Suite Reference Architecture 192
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
    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port telemetryOut;
        port dataOut;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port pwrIn;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port telemetryOut;
        port pwrIn;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port cmdOut;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
    }

    // System Definition
    public part def SensorSuiteSystem {
        part monitorsensor : MonitorSensor {
        }
        part sensoractuator : SensorActuator {
        }
        part commpayload : CommPayload {
        }
        part controlprocessor : ControlProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part powercomputer : PowerComputer {
            satisfy REQ_002;
        }
        part processingprocessor : ProcessingProcessor {
            satisfy REQ_002;
        }
        part monitorprocessor : MonitorProcessor {
        }

        // Connections
        connect sensoractuator.pwrIn to processingprocessor.cmdOut;
        connect powercomputer.dataOut to controlprocessor.pwrIn;
    }

    // System Instance
    part sensorsuitesystem : SensorSuiteSystem;

}