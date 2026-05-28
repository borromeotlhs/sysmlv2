package arch_000096 {

    import ScalarValues::*;

    // Lunar Habitat Reference Architecture 96
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

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
        port telemetryOut : ThermalIF;
        port ctrlIn : ThermalIF;
    }

    public part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : SignalIF;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : ThermalIF;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ControlIF;
    }

    public part def ThermalModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : DataIF;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part monitorbus : MonitorBus {
        }
        part thermalcontroller : ThermalController {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part sensorprocessor : SensorProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part navassembly : NavAssembly {
            satisfy REQ_001;
        }
        part thermalmodule : ThermalModule {
            satisfy REQ_003;
        }

        // Connections
        connect thermalcontroller.dataOut to sensorprocessor.dataOut;
        connect sensorprocessor.dataOut to monitorbus.pwrIn;
    }

    // System Instance
    public part lunarhabitatsystem : LunarHabitatSystem;

}