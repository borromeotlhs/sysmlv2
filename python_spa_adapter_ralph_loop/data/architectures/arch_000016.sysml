package arch_000016 {
	// Thruster Assembly Reference Architecture 16
	// Domain: thruster assembly

	import ScalarValues::*;

	// Interface Definitions
	interface def DiagnosticIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def ThrusterAssemblySystem {
	}

	part def ProcessingPayload {
		port cmdOut : SignalIF;
	}

	part def MonitorBus {
		port statusOut : ThermalIF;
	}

	part def NavPayload {
		port telemetryOut : DiagnosticIF;
		port pwrOut : TelemetryIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The thruster assembly system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The thruster assembly system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The thruster assembly system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The thruster assembly system shall maintain operational status monitoring. */
	}

	// System Assembly
	part thrusterassemblysystem : ThrusterAssemblySystem {
		part processingpayload : ProcessingPayload;
		part monitorbus : MonitorBus;
		part navpayload : NavPayload;

		// Connections
		connection : link1 connect 
			navpayload.telemetryOut to monitorbus.statusOut;
		connection : link2 connect 
			processingpayload.cmdOut to monitorbus.statusOut;
		connection : link3 connect 
			monitorbus.statusOut to navpayload.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingpayload;
		satisfy requirement <'REQ-001'> by navpayload;
		satisfy requirement <'REQ-002'> by processingpayload;
		satisfy requirement <'REQ-002'> by monitorbus;
		satisfy requirement <'REQ-003'> by monitorbus;
		satisfy requirement <'REQ-004'> by navpayload;
	}
}
