package arch_000039 {
	// Propulsion Module Reference Architecture 39
	// Domain: propulsion module

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def PropulsionModuleSystem {
	}

	part def ControlSubsystem {
		port ctrlIn : SignalIF;
		port ctrlIn : CommandIF;
	}

	part def DataProcessor {
		port statusOut : ConfigIF;
	}

	part def ThermalActuator {
		port dataOut : ThermalIF;
		port configIn : ControlIF;
	}

	part def ProcessingAssembly {
		port cmdIn : SignalIF;
	}

	part def NavSensor {
		port configIn : TelemetryIF;
		port pwrIn : ConfigIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The propulsion module system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The propulsion module system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The propulsion module system shall provide fault detection and recovery. */
	}

	// System Assembly
	part propulsionmodulesystem : PropulsionModuleSystem {
		part controlsubsystem : ControlSubsystem;
		part dataprocessor : DataProcessor;
		part thermalactuator : ThermalActuator;
		part processingassembly : ProcessingAssembly;
		part navsensor : NavSensor;

		// Connections
		connection : link1 connect 
			controlsubsystem.ctrlIn to navsensor.configIn;
		connection : link2 connect 
			thermalactuator.configIn to processingassembly.cmdIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingassembly;
		satisfy requirement <'REQ-002'> by navsensor;
		satisfy requirement <'REQ-003'> by thermalactuator;
	}
}
