package arch_000050 {

    // Fuel Cell Reference Architecture 50
    // Domain: fuel cell

    // Requirements
    requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrIn;
    }

    part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrOut;
    }

    part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port dataIn;
        port statusOut;
    }

    part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port configIn;
        port statusOut;
    }

    part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    // System Definition
    part def FuelCellSystem {
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
    part fuelcellsystem : FuelCellSystem;

}