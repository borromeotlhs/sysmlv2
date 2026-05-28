package arch_000010 {

    import ScalarValues::*;

    // Fuel Cell Reference Architecture 10
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DataIF;
        port pwrIn : ConfigIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : StatusIF;
        port pwrOut : StatusIF;
    }

    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : ConfigIF;
        port dataIn : ThermalIF;
        port statusOut : StatusIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DiagnosticIF;
        port configIn : SignalIF;
        port statusOut : ConfigIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : SignalIF;
    }

    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : DiagnosticIF;
    }

    // System Definition
    public part def FuelCellSystem {
        part monitorbus : MonitorBus {
            satisfy REQ_002;
        }
        part processingbus : ProcessingBus {
            satisfy REQ_001;
        }
        part monitormodule : MonitorModule {
        }
        part thermalsubsystem : ThermalSubsystem {
        }
        part flightinterface : FlightInterface {
        }
        part thermalactuator : ThermalActuator {
            satisfy REQ_001;
        }

        // Connections
        connect thermalsubsystem.dataIn to flightinterface.pwrIn;
        connect thermalactuator.statusOut to processingbus.telemetryOut;
        connect monitorbus.pwrIn to monitormodule.pwrIn;
        connect thermalsubsystem.statusOut to monitormodule.dataIn;
    }

    // System Instance
    public part fuelcellsystem : FuelCellSystem;

}