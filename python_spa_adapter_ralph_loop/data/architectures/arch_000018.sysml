package arch_000018 {
	// Solar Array Reference Architecture 18
	// Domain: solar array

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def SolarArraySystem {
	}

	part def PowerInterface {
		port cmdOut : PowerIF;
		port cmdIn : StatusIF;
		port ctrlIn : DiagnosticIF;
	}

	part def FlightProcessor {
		port pwrIn : CommandIF;
		port dataOut : SignalIF;
	}

	part def DataProcessor {
		port pwrIn : TelemetryIF;
		port cmdOut : ThermalIF;
		port pwrIn : DiagnosticIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The solar array system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The solar array system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The solar array system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The solar array system shall maintain operational status monitoring. */
	}

	// System Assembly
	part solararraysystem : SolarArraySystem {
		part powerinterface : PowerInterface;
		part flightprocessor : FlightProcessor;
		part dataprocessor : DataProcessor;

		// Connections
		connection : link1 connect 
			dataprocessor.cmdOut to powerinterface.cmdIn;
		connection : link2 connect 
			flightprocessor.pwrIn to powerinterface.ctrlIn;
		connection : link3 connect 
			dataprocessor.pwrIn to powerinterface.cmdIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by dataprocessor;
		satisfy requirement <'REQ-001'> by flightprocessor;
		satisfy requirement <'REQ-002'> by dataprocessor;
		satisfy requirement <'REQ-002'> by flightprocessor;
		satisfy requirement <'REQ-003'> by powerinterface;
		satisfy requirement <'REQ-003'> by dataprocessor;
		satisfy requirement <'REQ-004'> by dataprocessor;
		satisfy requirement <'REQ-004'> by flightprocessor;
	}
}
