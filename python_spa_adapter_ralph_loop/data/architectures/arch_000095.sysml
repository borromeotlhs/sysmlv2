package arch_000095 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : SignalIF;
        port dataOut : DiagnosticIF;
    }

    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : StatusIF;
    }

    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : SignalIF;
        port dataIn : StatusIF;
        port sensorOut : DataIF;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : ConfigIF;
        port pwrIn : ControlIF;
        port cmdOut : ConfigIF;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut : DiagnosticIF;
        port pwrIn : TelemetryIF;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : TelemetryIF;
        port dataOut : ControlIF;
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
    public part commanddatahandlingsystem : CommandDataHandlingSystem;

}