package arch_000131 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 131
    // Domain: instrument platform

    // Requirements
    public requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ControlIF;
    public port def PowerIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut : PowerIF;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : TelemetryIF;
    }

    public part def ControlPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : ControlIF;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
        part commmodule : CommModule {
        }
        part flightpayload : FlightPayload {
            satisfy REQ_002;
        }
        part controlpayload : ControlPayload {
            satisfy REQ_001;
        }

        // Connections
        connect flightpayload.configIn to controlpayload.statusOut;
        connect flightpayload.configIn to commmodule.statusOut;
    }

    // System Instance
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}