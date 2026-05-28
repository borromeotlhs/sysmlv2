package arch_000059 {

    // Solar Array Reference Architecture 59
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port ctrlIn;
        port configIn;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port telemetryOut;
        port cmdOut;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port dataOut;
    }

    public part def CommSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port pwrOut;
    }

    public part def ProcessingUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port ctrlIn;
        port telemetryOut;
    }

    // System Definition
    public part def SolarArraySystem {
        part commpayload : CommPayload {
        }
        part flightinterface : FlightInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part distributioncontroller : DistributionController {
            satisfy REQ_002;
        }
        part commsensor : CommSensor {
        }
        part processingunit : ProcessingUnit {
            satisfy REQ_001;
        }

        // Connections
        connect commpayload.ctrlIn to processingunit.dataIn;
        connect commpayload.configIn to distributioncontroller.dataOut;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}