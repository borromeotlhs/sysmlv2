package arch_000149 {

    import ScalarValues::*;

    // Fuel Cell Reference Architecture 149
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : ControlIF;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : CommandIF;
        port pwrIn : DataIF;
        port ctrlIn : TelemetryIF;
    }

    public part def CommComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : ControlIF;
        port statusOut : DataIF;
        port dataIn : SignalIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut : ControlIF;
        port statusOut : DiagnosticIF;
        port sensorOut : ControlIF;
    }

    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : CommandIF;
        port telemetryOut : PowerIF;
    }

    public part def DistributionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
        port cmdIn : StatusIF;
        port dataOut : SignalIF;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port configIn : DataIF;
        port cmdOut : PowerIF;
    }

    // System Definition
    public part def FuelCellSystem {
        part flightsensor : FlightSensor {
            satisfy REQ_002;
        }
        part datapayload : DataPayload {
        }
        part commcomputer : CommComputer {
            satisfy REQ_001;
        }
        part communit : CommUnit {
        }
        part powercontroller : PowerController {
        }
        part distributionmodule : DistributionModule {
        }
        part powermodule : PowerModule {
            satisfy REQ_001;
        }

        // Connections
        connect powermodule.cmdOut to commcomputer.statusOut;
        connect distributionmodule.cmdIn to powercontroller.cmdIn;
        connect powermodule.configIn to commcomputer.statusOut;
    }

    // System Instance
    public part fuelcellsystem : FuelCellSystem;

}