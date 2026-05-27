package arch_000017 {
	// Robotic Arm Reference Architecture 17
	// Domain: robotic arm

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def DiagnosticIF;
	interface def TelemetryIF;

	// Part Definitions
	part def RoboticArmSystem {
	}

	part def PowerComputer {
		port telemetryOut : TelemetryIF;
	}

	part def MissionSensor {
		port cmdIn : DiagnosticIF;
	}

	part def PowerBus {
		port ctrlIn : TelemetryIF;
		port ctrlIn : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The robotic arm system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The robotic arm system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The robotic arm system shall provide fault detection and recovery. */
	}

	// System Assembly
	part roboticarmsystem : RoboticArmSystem {
		part powercomputer : PowerComputer;
		part missionsensor : MissionSensor;
		part powerbus : PowerBus;

		// Connections
		connection : link1 connect 
			powercomputer.telemetryOut to powerbus.ctrlIn;
		connection : link2 connect 
			missionsensor.cmdIn to powercomputer.telemetryOut;
		connection : link3 connect 
			powerbus.ctrlIn to missionsensor.cmdIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by missionsensor;
		satisfy requirement <'REQ-001'> by powerbus;
		satisfy requirement <'REQ-002'> by missionsensor;
		satisfy requirement <'REQ-002'> by powercomputer;
		satisfy requirement <'REQ-003'> by powercomputer;
	}
}
