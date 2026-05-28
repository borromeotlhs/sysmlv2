package arch_000060 {

    import ScalarValues::*;

    // Lunar Habitat Reference Architecture 60
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The lunar habitat system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The lunar habitat system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DataIF;
        port cmdOut : CommandIF;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DataIF;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ThermalIF;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : TelemetryIF;
        port cmdIn : CommandIF;
        port pwrOut : DataIF;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn : TelemetryIF;
        port cmdOut : ThermalIF;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut : DataIF;
        port cmdOut : ControlIF;
    }

    public part def ProcessingModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
        port statusOut : PowerIF;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part thermalunit : ThermalUnit {
            satisfy REQ_004;
        }
        part flightassembly : FlightAssembly {
            satisfy REQ_003;
        }
        part monitorinterface : MonitorInterface {
        }
        part commandcomputer : CommandComputer {
            satisfy REQ_002;
        }
        part comminterface : CommInterface {
        }
        part powerbus : PowerBus {
            satisfy REQ_001;
        }
        part processingmodule : ProcessingModule {
            satisfy REQ_003;
        }

        // Connections
        connect thermalunit.cmdOut to comminterface.cmdOut;
        connect thermalunit.telemetryOut to powerbus.cmdOut;
        connect flightassembly.ctrlIn to comminterface.dataIn;
    }

    // System Instance
    public part lunarhabitatsystem : LunarHabitatSystem;

}