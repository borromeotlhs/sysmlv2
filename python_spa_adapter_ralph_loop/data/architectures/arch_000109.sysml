package arch_000109 {

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

    // Component Definitions
    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port dataOut;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port sensorOut;
        port configIn;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port statusOut;
        port telemetryOut;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port cmdIn;
        port telemetryOut;
    }

    public part def NavComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
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
    part satellitebussystem : SatelliteBusSystem;

}