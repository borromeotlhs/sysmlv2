package arch_000014 {
	// Avionics Bay Reference Architecture 14
	// Domain: avionics bay

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def ThermalIF;

	// Part Definitions
	part def AvionicsBaySystem {
	}

	part def ControlProcessor {
		port telemetryOut : DataIF;
		port configIn : ThermalIF;
	}

	part def DataProcessor {
		port pwrIn : ControlIF;
		port dataIn : DiagnosticIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The avionics bay system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The avionics bay system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The avionics bay system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The avionics bay system shall maintain operational status monitoring. */
	}

	// System Assembly
	part avionicsbaysystem : AvionicsBaySystem {
		part controlprocessor : ControlProcessor;
		part dataprocessor : DataProcessor;

		// Connections
		connection : link1 connect 
			controlprocessor.configIn to dataprocessor.pwrIn;
		connection : link2 connect 
			controlprocessor.telemetryOut to dataprocessor.pwrIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by dataprocessor;
		satisfy requirement <'REQ-001'> by controlprocessor;
		satisfy requirement <'REQ-002'> by controlprocessor;
		satisfy requirement <'REQ-003'> by dataprocessor;
		satisfy requirement <'REQ-004'> by controlprocessor;
	}
}
