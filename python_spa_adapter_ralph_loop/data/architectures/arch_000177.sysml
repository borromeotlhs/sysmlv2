package arch_000177 {

    import ScalarValues::*;

    // Satellite Bus Reference Architecture 177
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
    public port def PowerIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : PowerIF;
        port ctrlIn : ControlIF;
        port dataIn : ThermalIF;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : ConfigIF;
        port dataOut : TelemetryIF;
        port cmdIn : ConfigIF;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part powercontroller : PowerController {
            satisfy REQ_002;
        }
        part sensorbus : SensorBus {
            satisfy REQ_001;
        }
        part commprocessor : CommProcessor {
        }

        // Connections
        connect sensorbus.dataIn to commprocessor.dataOut;
        connect sensorbus.dataIn to powercontroller.telemetryOut;
    }

    // System Instance
    public part satellitebussystem : SatelliteBusSystem;

}