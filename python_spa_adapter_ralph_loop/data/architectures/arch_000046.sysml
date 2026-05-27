package arch_000046 {
	// Telemetry System Reference Architecture 46
	// Domain: telemetry system

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def PowerIF;
	interface def StatusIF;
	interface def TelemetryIF;

	// Part Definitions
	part def TelemetrySystemSystem {
	}

	part def ProcessingController {
		port dataIn : PowerIF;
		port telemetryOut : StatusIF;
	}

	part def SensorComputer {
		port statusOut : TelemetryIF;
		port statusOut : StatusIF;
	}

	part def FlightPayload {
		port telemetryOut : ConfigIF;
	}

	part def MissionUnit {
		port telemetryOut : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The telemetry system system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The telemetry system system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part telemetrysystemsystem : TelemetrySystemSystem {
		part processingcontroller : ProcessingController;
		part sensorcomputer : SensorComputer;
		part flightpayload : FlightPayload;
		part missionunit : MissionUnit;

		// Connections
		connection : link1 connect 
			processingcontroller.telemetryOut to flightpayload.telemetryOut;
		connection : link2 connect 
			missionunit.telemetryOut to processingcontroller.telemetryOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by missionunit;
		satisfy requirement <'REQ-001'> by flightpayload;
		satisfy requirement <'REQ-002'> by missionunit;
		satisfy requirement <'REQ-002'> by processingcontroller;
	}
}
