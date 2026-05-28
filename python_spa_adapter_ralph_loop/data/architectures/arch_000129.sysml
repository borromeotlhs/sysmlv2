package arch_000129 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 129
    // Domain: instrument platform

    // Requirements
    public requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : TelemetryIF;
        port dataIn : ThermalIF;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : SignalIF;
    }

    public part def MissionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : StatusIF;
        port dataOut : PowerIF;
        port configIn : CommandIF;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : TelemetryIF;
        port configIn : DataIF;
        port telemetryOut : SignalIF;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : CommandIF;
        port sensorOut : ThermalIF;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ConfigIF;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ControlIF;
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
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}