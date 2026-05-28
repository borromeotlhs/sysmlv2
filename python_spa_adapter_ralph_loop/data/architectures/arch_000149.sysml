package arch_000149 {

    // Fuel Cell Reference Architecture 149
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
        port pwrIn;
        port ctrlIn;
    }

    public part def CommComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port statusOut;
        port dataIn;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
        port statusOut;
        port sensorOut;
    }

    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port telemetryOut;
    }

    public part def DistributionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port cmdIn;
        port dataOut;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port configIn;
        port cmdOut;
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
    part fuelcellsystem : FuelCellSystem;

}