package arch_000029 {
	// Propulsion Module Reference Architecture 29
	// Domain: propulsion module

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def PowerIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def PropulsionModuleSystem {
	}

	part def DistributionProcessor {
		port cmdIn : TelemetryIF;
	}

	part def DistributionUnit {
		port statusOut : PowerIF;
		port dataIn : StatusIF;
		port sensorOut : ThermalIF;
	}

	part def PowerAssembly {
		port sensorOut : ControlIF;
		port cmdOut : StatusIF;
		port cmdIn : StatusIF;
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
		part distributionprocessor : DistributionProcessor;
		part distributionunit : DistributionUnit;
		part powerassembly : PowerAssembly;

		// Connections
		connection : link1 connect 
			distributionunit.sensorOut to distributionprocessor.cmdIn;
		connection : link2 connect 
			powerassembly.sensorOut to distributionunit.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributionunit;
		satisfy requirement <'REQ-001'> by distributionprocessor;
		satisfy requirement <'REQ-002'> by distributionprocessor;
		satisfy requirement <'REQ-002'> by distributionunit;
		satisfy requirement <'REQ-003'> by powerassembly;
	}
}
