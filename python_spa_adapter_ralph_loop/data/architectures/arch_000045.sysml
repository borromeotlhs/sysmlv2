package arch_000045 {
	// Robotic Arm Reference Architecture 45
	// Domain: robotic arm

	import ScalarValues::*;

	// Interface Definitions
	interface def PowerIF;
	interface def TelemetryIF;

	// Part Definitions
	part def RoboticArmSystem {
	}

	part def CommandAssembly {
		port configIn : TelemetryIF;
	}

	part def SensorPayload {
		port sensorOut : TelemetryIF;
	}

	part def FlightInterface {
		port ctrlIn : PowerIF;
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
		part commandassembly : CommandAssembly;
		part sensorpayload : SensorPayload;
		part flightinterface : FlightInterface;

		// Connections
		connection : link1 connect 
			sensorpayload.sensorOut to flightinterface.ctrlIn;
		connection : link2 connect 
			flightinterface.ctrlIn to commandassembly.configIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by flightinterface;
		satisfy requirement <'REQ-002'> by flightinterface;
		satisfy requirement <'REQ-003'> by commandassembly;
	}
}
