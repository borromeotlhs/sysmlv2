package arch_000163 {

    // Solar Array Reference Architecture 163
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port pwrIn;
        port dataOut;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port configIn;
    }

    public part def ControlComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port ctrlIn;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
        port statusOut;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port pwrIn;
        port cmdOut;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port dataIn;
        port pwrIn;
    }

    // System Definition
    public part def SolarArraySystem {
        part flightmodule : FlightModule {
            satisfy REQ_001;
        }
        part controlsensor : ControlSensor {
        }
        part controlcomputer : ControlComputer {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part datapayload : DataPayload {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part sensorcomputer : SensorComputer {
        }
        part flightinterface : FlightInterface {
        }

        // Connections
        connect controlsensor.configIn to controlcomputer.ctrlIn;
        connect sensorcomputer.pwrOut to controlcomputer.configIn;
        connect flightmodule.dataIn to sensorcomputer.cmdOut;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}