package arch_000147 {

    import ScalarValues::*;

    // Fuel Cell Reference Architecture 147
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The fuel cell system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def SignalIF;

    // Component Definitions
    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : PowerIF;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : SignalIF;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut : PowerIF;
        port telemetryOut : CommandIF;
        port ctrlIn : CommandIF;
    }

    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ControlIF;
    }

    // System Definition
    public part def FuelCellSystem {
        part navpayload : NavPayload {
            satisfy REQ_001;
        }
        part sensorsubsystem : SensorSubsystem {
        }
        part comminterface : CommInterface {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part missionmodule : MissionModule {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect navpayload.pwrIn to comminterface.telemetryOut;
        connect missionmodule.cmdOut to sensorsubsystem.pwrIn;
        connect navpayload.pwrIn to comminterface.ctrlIn;
        connect missionmodule.cmdOut to comminterface.ctrlIn;
    }

    // System Instance
    public part fuelcellsystem : FuelCellSystem;

}