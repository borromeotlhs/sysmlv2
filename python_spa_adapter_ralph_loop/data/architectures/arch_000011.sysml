package arch_000011 {
	// Autonomous Rover Reference Architecture 11
	// Domain: autonomous rover

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def AutonomousRoverSystem {
	}

	part def NavActuator {
		port configIn : ThermalIF;
		port statusOut : TelemetryIF;
		port statusOut : ThermalIF;
	}

	part def DistributionController {
		port telemetryOut : CommandIF;
	}

	part def NavSubsystem {
		port statusOut : ThermalIF;
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

	requirement <'REQ-004'> {
		doc /* The autonomous rover system shall maintain operational status monitoring. */
	}

	// System Assembly
	part autonomousroversystem : AutonomousRoverSystem {
		part navactuator : NavActuator;
		part distributioncontroller : DistributionController;
		part navsubsystem : NavSubsystem;

		// Connections
		connection : link1 connect 
			navsubsystem.statusOut to distributioncontroller.telemetryOut;
		connection : link2 connect 
			navsubsystem.statusOut to navactuator.statusOut;
		connection : link3 connect 
			distributioncontroller.telemetryOut to navactuator.statusOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributioncontroller;
		satisfy requirement <'REQ-001'> by navsubsystem;
		satisfy requirement <'REQ-002'> by navactuator;
		satisfy requirement <'REQ-002'> by distributioncontroller;
		satisfy requirement <'REQ-003'> by distributioncontroller;
		satisfy requirement <'REQ-003'> by navactuator;
		satisfy requirement <'REQ-004'> by navsubsystem;
		satisfy requirement <'REQ-004'> by distributioncontroller;
	}
}
