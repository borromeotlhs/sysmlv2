package arch_000084 {

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

    // Component Definitions
    public part def ProcessingComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port pwrOut;
        port statusOut;
    }

    public part def ControlPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
        port statusOut;
        port pwrIn;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
    }

    public part def ProcessingActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port sensorOut;
        port sensorOut;
    }

    public part def CommandBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
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
    part uavpayloadsystem : UavPayloadSystem;

}