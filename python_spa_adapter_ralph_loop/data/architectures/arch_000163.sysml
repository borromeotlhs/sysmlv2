package arch_000163 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : CommandIF;
        port pwrIn : ThermalIF;
        port dataOut : DiagnosticIF;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : ConfigIF;
        port configIn : ControlIF;
    }

    public part def ControlComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : CommandIF;
        port ctrlIn : CommandIF;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : PowerIF;
        port statusOut : CommandIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : StatusIF;
        port pwrIn : DataIF;
        port cmdOut : DataIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : SignalIF;
        port dataIn : PowerIF;
        port pwrIn : DataIF;
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
    public part solararraysystem : SolarArraySystem;

}