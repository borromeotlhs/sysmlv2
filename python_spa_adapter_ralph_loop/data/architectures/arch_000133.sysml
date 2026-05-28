package arch_000133 {

    import ScalarValues::*;

    // Imaging Payload Reference Architecture 133
    // Domain: imaging payload

    // Requirements
    public requirement REQ_001 {
        doc "The imaging payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The imaging payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The imaging payload system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The imaging payload system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ThermalIF;
        port dataIn : ControlIF;
        port pwrIn : ThermalIF;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : CommandIF;
        port ctrlIn : SignalIF;
        port dataIn : TelemetryIF;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : CommandIF;
        port ctrlIn : TelemetryIF;
        port dataIn : StatusIF;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : TelemetryIF;
    }

    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
        port telemetryOut : DataIF;
        port statusOut : ControlIF;
    }

    // System Definition
    public part def ImagingPayloadSystem {
        part navbus : NavBus {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part flightpayload : FlightPayload {
        }
        part navmodule : NavModule {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part flightsensor : FlightSensor {
            satisfy REQ_004;
        }
        part distributioncomputer : DistributionComputer {
        }

        // Connections
        connect flightpayload.ctrlIn to navmodule.configIn;
        connect distributioncomputer.telemetryOut to flightsensor.pwrOut;
    }

    // System Instance
    public part imagingpayloadsystem : ImagingPayloadSystem;

}