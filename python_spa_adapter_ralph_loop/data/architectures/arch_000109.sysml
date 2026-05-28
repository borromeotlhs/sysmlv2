package arch_000109 {

    import ScalarValues::*;

    // Satellite Bus Reference Architecture 109
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The satellite bus system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : ConfigIF;
        port dataOut : ThermalIF;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : SignalIF;
        port sensorOut : TelemetryIF;
        port configIn : PowerIF;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
        port statusOut : DiagnosticIF;
        port telemetryOut : ConfigIF;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : ThermalIF;
    }

    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : SignalIF;
        port cmdIn : TelemetryIF;
        port telemetryOut : CommandIF;
    }

    public part def NavComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : SignalIF;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part missionmodule : MissionModule {
        }
        part controlprocessor : ControlProcessor {
            satisfy REQ_002;
        }
        part powercomputer : PowerComputer {
        }
        part thermalbus : ThermalBus {
        }
        part distributioncontroller : DistributionController {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part powerpayload : PowerPayload {
        }
        part navcomputer : NavComputer {
            satisfy REQ_001;
        }

        // Connections
        connect navcomputer.statusOut to missionmodule.dataOut;
        connect controlprocessor.configIn to navcomputer.statusOut;
        connect powercomputer.statusOut to controlprocessor.sensorOut;
        connect thermalbus.pwrIn to powerpayload.cmdIn;
    }

    // System Instance
    public part satellitebussystem : SatelliteBusSystem;

}