package arch_000031 {
	// Autonomous Rover Reference Architecture 31
	// Domain: autonomous rover

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def DiagnosticIF;
	interface def TelemetryIF;

	// Part Definitions
	part def AutonomousRoverSystem {
	}

	part def ThermalUnit {
		port configIn : DiagnosticIF;
	}

	part def FlightInterface {
		port statusOut : TelemetryIF;
		port configIn : ConfigIF;
		port cmdIn : TelemetryIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The autonomous rover system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The autonomous rover system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The autonomous rover system shall provide fault detection and recovery. */
	}

	// System Assembly
	part autonomousroversystem : AutonomousRoverSystem {
		part thermalunit : ThermalUnit;
		part flightinterface : FlightInterface;

		// Connections
		connection : link1 connect 
			flightinterface.statusOut to thermalunit.configIn;
		connection : link2 connect 
			thermalunit.configIn to flightinterface.configIn;
		connection : link3 connect 
			thermalunit.configIn to flightinterface.cmdIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by flightinterface;
		satisfy requirement <'REQ-002'> by thermalunit;
		satisfy requirement <'REQ-003'> by flightinterface;
		satisfy requirement <'REQ-003'> by thermalunit;
	}
}
