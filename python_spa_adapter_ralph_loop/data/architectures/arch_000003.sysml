package arch_000003 {
	// Instrument Platform Reference Architecture 3
	// Domain: instrument platform

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def DataIF;
	interface def StatusIF;

	// Part Definitions
	part def InstrumentPlatformSystem {
	}

	part def CommandInterface {
		port statusOut : StatusIF;
	}

	part def CommActuator {
		port ctrlIn : ConfigIF;
		port pwrIn : ConfigIF;
		port cmdIn : DataIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The instrument platform system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The instrument platform system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The instrument platform system shall provide fault detection and recovery. */
	}

	// System Assembly
	part instrumentplatformsystem : InstrumentPlatformSystem {
		part commandinterface : CommandInterface;
		part commactuator : CommActuator;

		// Connections
		connection : link1 connect 
			commactuator.pwrIn to commandinterface.statusOut;
		connection : link2 connect 
			commactuator.cmdIn to commandinterface.statusOut;
		connection : link3 connect 
			commactuator.ctrlIn to commandinterface.statusOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by commandinterface;
		satisfy requirement <'REQ-002'> by commandinterface;
		satisfy requirement <'REQ-002'> by commactuator;
		satisfy requirement <'REQ-003'> by commactuator;
		satisfy requirement <'REQ-003'> by commandinterface;
	}
}
