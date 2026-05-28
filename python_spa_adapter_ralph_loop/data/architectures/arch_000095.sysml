package arch_000095 {

    // Command Data Handling Reference Architecture 95
    // Domain: command data handling

    // Requirements
    public requirement REQ_001 {
        doc "The command data handling system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The command data handling system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The command data handling system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port dataOut;
    }

    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
    }

    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port dataIn;
        port sensorOut;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port pwrIn;
        port cmdOut;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut;
        port pwrIn;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port dataOut;
    }

    // System Definition
    public part def CommandDataHandlingSystem {
        part datasensor : DataSensor {
        }
        part missionbus : MissionBus {
            satisfy REQ_003;
        }
        part processingcontroller : ProcessingController {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part flightsensor : FlightSensor {
        }
        part powerbus : PowerBus {
            satisfy REQ_001;
        }
        part sensoractuator : SensorActuator {
            satisfy REQ_002;
        }

        // Connections
        connect powerbus.pwrIn to flightsensor.pwrIn;
        connect datasensor.pwrOut to flightsensor.pwrIn;
        connect processingcontroller.dataIn to datasensor.dataOut;
        connect powerbus.pwrIn to sensoractuator.dataOut;
        connect powerbus.pwrIn to sensoractuator.configIn;
    }

    // System Instance
    part commanddatahandlingsystem : CommandDataHandlingSystem;

}