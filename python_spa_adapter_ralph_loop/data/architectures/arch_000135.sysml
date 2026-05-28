package arch_000135 {

    import ScalarValues::*;

    // Satellite Bus Reference Architecture 135
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : CommandIF;
        port pwrIn : ThermalIF;
    }

    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdIn : ThermalIF;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : ControlIF;
        port statusOut : DiagnosticIF;
        port pwrOut : ControlIF;
    }

    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ConfigIF;
        port sensorOut : TelemetryIF;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : DiagnosticIF;
        port dataIn : SignalIF;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : ThermalIF;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : SignalIF;
        port cmdIn : PowerIF;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part commandpayload : CommandPayload {
            satisfy REQ_001;
        }
        part commandmodule : CommandModule {
        }
        part sensorinterface : SensorInterface {
            satisfy REQ_002;
        }
        part missionunit : MissionUnit {
        }
        part comminterface : CommInterface {
        }
        part sensorprocessor : SensorProcessor {
        }
        part navassembly : NavAssembly {
        }

        // Connections
        connect sensorinterface.statusOut to missionunit.sensorOut;
        connect comminterface.dataIn to commandmodule.cmdIn;
        connect sensorinterface.statusOut to commandmodule.cmdIn;
        connect sensorprocessor.pwrIn to navassembly.cmdIn;
    }

    // System Instance
    public part satellitebussystem : SatelliteBusSystem;

}