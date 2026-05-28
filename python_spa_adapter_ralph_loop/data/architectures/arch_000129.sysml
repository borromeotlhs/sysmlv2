package arch_000129 {

    // Instrument Platform Reference Architecture 129
    // Domain: instrument platform

    // Requirements
    public requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port dataIn;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
    }

    public part def MissionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port dataOut;
        port configIn;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port configIn;
        port telemetryOut;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port sensorOut;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
        part controlsubsystem : ControlSubsystem {
        }
        part distributionprocessor : DistributionProcessor {
            satisfy REQ_001;
        }
        part missionpayload : MissionPayload {
        }
        part flightcomputer : FlightComputer {
            satisfy REQ_001;
        }
        part missionprocessor : MissionProcessor {
        }
        part flightbus : FlightBus {
            satisfy REQ_002;
        }
        part monitoractuator : MonitorActuator {
        }

        // Connections
        connect flightcomputer.configIn to monitoractuator.configIn;
        connect missionprocessor.sensorOut to missionpayload.ctrlIn;
        connect controlsubsystem.statusOut to missionpayload.ctrlIn;
    }

    // System Instance
    part instrumentplatformsystem : InstrumentPlatformSystem;

}