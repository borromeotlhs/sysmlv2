package arch_000010 {
	// Fuel Cell Reference Architecture 10
	// Domain: fuel cell

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def FuelCellSystem {
	}

	part def MonitorBus {
		port telemetryOut : DataIF;
		port pwrIn : ConfigIF;
	}

	part def ProcessingBus {
		port telemetryOut : StatusIF;
		port pwrOut : StatusIF;
	}

	part def MonitorModule {
		port pwrIn : ConfigIF;
		port dataIn : ThermalIF;
		port statusOut : StatusIF;
	}

	part def ThermalSubsystem {
		port dataIn : DiagnosticIF;
		port configIn : SignalIF;
		port statusOut : ConfigIF;
	}

	part def FlightInterface {
		port pwrIn : SignalIF;
	}

	part def ThermalActuator {
		port statusOut : DiagnosticIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The fuel cell system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The fuel cell system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part fuelcellsystem : FuelCellSystem {
		part monitorbus : MonitorBus;
		part processingbus : ProcessingBus;
		part monitormodule : MonitorModule;
		part thermalsubsystem : ThermalSubsystem;
		part flightinterface : FlightInterface;
		part thermalactuator : ThermalActuator;

		// Connections
		connection : link1 connect 
			thermalsubsystem.dataIn to flightinterface.pwrIn;
		connection : link2 connect 
			thermalactuator.statusOut to processingbus.telemetryOut;
		connection : link3 connect 
			monitorbus.pwrIn to monitormodule.pwrIn;
		connection : link4 connect 
			thermalsubsystem.statusOut to monitormodule.dataIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingbus;
		satisfy requirement <'REQ-001'> by thermalactuator;
		satisfy requirement <'REQ-002'> by monitorbus;
	}
}
