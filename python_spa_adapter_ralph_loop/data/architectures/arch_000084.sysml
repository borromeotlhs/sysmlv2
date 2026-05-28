package arch_000084 {

    import ScalarValues::*;

    // Uav Payload Reference Architecture 84
    // Domain: uav payload

    // Requirements
    public requirement REQ_001 {
        doc "The uav payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The uav payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The uav payload system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The uav payload system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ProcessingComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : StatusIF;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : DiagnosticIF;
        port pwrOut : ConfigIF;
        port statusOut : StatusIF;
    }

    public part def ControlPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : SignalIF;
        port statusOut : ControlIF;
        port pwrIn : TelemetryIF;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : StatusIF;
    }

    public part def ProcessingActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : SignalIF;
        port sensorOut : ControlIF;
        port sensorOut : ThermalIF;
    }

    public part def CommandBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : DiagnosticIF;
    }

    // System Definition
    public part def UavPayloadSystem {
        part processingcomputer : ProcessingComputer {
            satisfy REQ_004;
        }
        part sensorsubsystem : SensorSubsystem {
        }
        part controlpayload : ControlPayload {
            satisfy REQ_001;
        }
        part sensorprocessor : SensorProcessor {
            satisfy REQ_004;
        }
        part processingactuator : ProcessingActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commandbus : CommandBus {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect processingactuator.sensorOut to controlpayload.statusOut;
        connect sensorsubsystem.pwrOut to commandbus.dataOut;
        connect sensorsubsystem.pwrOut to processingactuator.sensorOut;
        connect commandbus.dataOut to processingactuator.sensorOut;
    }

    // System Instance
    public part uavpayloadsystem : UavPayloadSystem;

}