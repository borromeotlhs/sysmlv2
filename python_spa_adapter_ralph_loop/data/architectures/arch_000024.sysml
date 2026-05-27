package arch_000024 {
	// Robotic Arm Reference Architecture 24
	// Domain: robotic arm

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def SignalIF;
	interface def TelemetryIF;

	// Part Definitions
	part def RoboticArmSystem {
	}

	part def ControlModule {
		port statusOut : DataIF;
		port dataIn : CommandIF;
		port cmdIn : SignalIF;
	}

	part def MonitorController {
		port cmdOut : DataIF;
		port dataOut : ConfigIF;
	}

	part def MonitorPayload {
		port statusOut : TelemetryIF;
	}

	part def ProcessingUnit {
		port telemetryOut : ConfigIF;
		port statusOut : DiagnosticIF;
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
		part controlmodule : ControlModule;
		part monitorcontroller : MonitorController;
		part monitorpayload : MonitorPayload;
		part processingunit : ProcessingUnit;

		// Connections
		connection : link1 connect 
			processingunit.telemetryOut to controlmodule.dataIn;
		connection : link2 connect 
			processingunit.telemetryOut to monitorcontroller.dataOut;
		connection : link3 connect 
			monitorpayload.statusOut to monitorcontroller.cmdOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by monitorpayload;
		satisfy requirement <'REQ-002'> by monitorpayload;
		satisfy requirement <'REQ-003'> by controlmodule;
		satisfy requirement <'REQ-003'> by monitorcontroller;
	}
}
