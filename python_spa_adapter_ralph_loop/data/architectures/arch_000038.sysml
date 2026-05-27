package arch_000038 {
	// Autonomous Rover Reference Architecture 38
	// Domain: autonomous rover

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def AutonomousRoverSystem {
	}

	part def FlightComputer {
		port telemetryOut : ThermalIF;
		port configIn : StatusIF;
	}

	part def MonitorActuator {
		port telemetryOut : CommandIF;
		port ctrlIn : ConfigIF;
		port pwrIn : SignalIF;
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
		part flightcomputer : FlightComputer;
		part monitoractuator : MonitorActuator;

		// Connections
		connection : link1 connect 
			flightcomputer.configIn to monitoractuator.ctrlIn;
		connection : link2 connect 
			monitoractuator.ctrlIn to flightcomputer.telemetryOut;
		connection : link3 connect 
			flightcomputer.configIn to monitoractuator.telemetryOut;
		connection : link4 connect 
			flightcomputer.telemetryOut to monitoractuator.telemetryOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by monitoractuator;
		satisfy requirement <'REQ-002'> by flightcomputer;
		satisfy requirement <'REQ-002'> by monitoractuator;
		satisfy requirement <'REQ-003'> by flightcomputer;
	}
}
