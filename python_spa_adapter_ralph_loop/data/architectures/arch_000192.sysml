package arch_000192 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : DiagnosticIF;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : CommandIF;
        port telemetryOut : ControlIF;
        port dataOut : DiagnosticIF;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : PowerIF;
        port ctrlIn : ControlIF;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : SignalIF;
        port pwrIn : StatusIF;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : SignalIF;
        port telemetryOut : DataIF;
        port pwrIn : StatusIF;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : DataIF;
        port cmdOut : ThermalIF;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : DiagnosticIF;
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
    public part sensorsuitesystem : SensorSuiteSystem;

}