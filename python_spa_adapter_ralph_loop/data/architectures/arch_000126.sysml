package arch_000126 {

    // Data Processing Unit Reference Architecture 126
    // Domain: data processing unit

    // Requirements
    public requirement REQ_001 {
        doc "The data processing unit system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The data processing unit system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port cmdIn;
    }

    public part def MonitorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port dataIn;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port statusOut;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    // System Definition
    public part def DataProcessingUnitSystem {
        part commprocessor : CommProcessor {
        }
        part monitorpayload : MonitorPayload {
        }
        part flightprocessor : FlightProcessor {
        }
        part sensorsubsystem : SensorSubsystem {
            satisfy REQ_002;
        }
        part dataactuator : DataActuator {
            satisfy REQ_001;
        }
        part monitorcontroller : MonitorController {
        }

        // Connections
        connect commprocessor.cmdIn to monitorcontroller.sensorOut;
        connect commprocessor.pwrIn to dataactuator.dataIn;
        connect flightprocessor.dataIn to dataactuator.dataIn;
        connect commprocessor.cmdIn to sensorsubsystem.telemetryOut;
        connect dataactuator.statusOut to flightprocessor.dataIn;
    }

    // System Instance
    part dataprocessingunitsystem : DataProcessingUnitSystem;

}