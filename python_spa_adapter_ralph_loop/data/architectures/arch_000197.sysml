package arch_000197 {

    import ScalarValues::*;

    // Satellite Bus Reference Architecture 197
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

    public requirement REQ_004 {
        doc "The satellite bus system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : CommandIF;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ControlIF;
    }

    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : TelemetryIF;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : DataIF;
        port statusOut : PowerIF;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part thermalunit : ThermalUnit {
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part thermalbus : ThermalBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part commmodule : CommModule {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part thermalcomputer : ThermalComputer {
            satisfy REQ_003;
        }

        // Connections
        connect thermalcomputer.configIn to commmodule.pwrIn;
        connect commmodule.pwrIn to thermalunit.cmdIn;
        connect thermalunit.cmdIn to thermalcomputer.statusOut;
        connect commmodule.pwrIn to thermalcomputer.statusOut;
    }

    // System Instance
    public part satellitebussystem : SatelliteBusSystem;

}