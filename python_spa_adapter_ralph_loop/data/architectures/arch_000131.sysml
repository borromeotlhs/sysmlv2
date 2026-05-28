package arch_000131 {

    // Instrument Platform Reference Architecture 131
    // Domain: instrument platform

    // Requirements
    public requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
    }

    public part def ControlPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
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
    part instrumentplatformsystem : InstrumentPlatformSystem;

}