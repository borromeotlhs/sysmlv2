package arch_000042 {
	// Thruster Assembly Reference Architecture 42
	// Domain: thruster assembly

	import ScalarValues::*;

	// Interface Definitions
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def ThermalIF;

	// Part Definitions
	part def ThrusterAssemblySystem {
	}

	part def PowerComputer {
		port telemetryOut : SignalIF;
		port ctrlIn : ThermalIF;
	}

	part def PowerBus {
		port sensorOut : SignalIF;
	}

	part def FlightAssembly {
		port pwrIn : PowerIF;
		port cmdOut : DiagnosticIF;
		port configIn : ThermalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The thruster assembly system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The thruster assembly system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part thrusterassemblysystem : ThrusterAssemblySystem {
		part powercomputer : PowerComputer;
		part powerbus : PowerBus;
		part flightassembly : FlightAssembly;

		// Connections
		connection : link1 connect 
			powercomputer.telemetryOut to flightassembly.configIn;
		connection : link2 connect 
			powercomputer.ctrlIn to flightassembly.configIn;
		connection : link3 connect 
			flightassembly.pwrIn to powerbus.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by powercomputer;
		satisfy requirement <'REQ-002'> by powerbus;
	}
}
