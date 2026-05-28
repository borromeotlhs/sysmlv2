package arch_000059 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 59
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : TelemetryIF;
        port ctrlIn : ControlIF;
        port configIn : CommandIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : TelemetryIF;
        port telemetryOut : ControlIF;
        port cmdOut : ConfigIF;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : StatusIF;
        port dataOut : TelemetryIF;
    }

    public part def CommSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : SignalIF;
        port pwrOut : ConfigIF;
    }

    public part def ProcessingUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DiagnosticIF;
        port ctrlIn : ControlIF;
        port telemetryOut : CommandIF;
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
    public part solararraysystem : SolarArraySystem;

}