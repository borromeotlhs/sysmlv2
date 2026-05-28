package arch_000050 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 50
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The communication relay system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : CommandIF;
        port statusOut : PowerIF;
        port telemetryOut : ThermalIF;
    }

    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : CommandIF;
    }

    public part def ProcessingSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : TelemetryIF;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : DiagnosticIF;
        port telemetryOut : DiagnosticIF;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : TelemetryIF;
        port cmdIn : CommandIF;
    }

    public part def MissionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : StatusIF;
        port cmdIn : CommandIF;
        port sensorOut : SignalIF;
    }

    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : CommandIF;
        port sensorOut : StatusIF;
        port dataIn : DataIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part distributionassembly : DistributionAssembly {
        }
        part commandprocessor : CommandProcessor {
        }
        part processingsensor : ProcessingSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part navprocessor : NavProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part sensorinterface : SensorInterface {
            satisfy REQ_003;
        }
        part missionsensor : MissionSensor {
        }
        part missioncontroller : MissionController {
        }

        // Connections
        connect sensorinterface.cmdIn to distributionassembly.telemetryOut;
        connect commandprocessor.dataIn to missionsensor.sensorOut;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}