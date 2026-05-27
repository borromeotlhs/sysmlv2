package arch_000001 {
	// Solar Array Reference Architecture 1
	// Domain: solar array

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def DataIF;
	interface def StatusIF;

	// Part Definitions
	part def SolarArraySystem {
	}

	part def MissionBus {
		port dataIn : DataIF;
	}

	part def PowerModule {
		port sensorOut : DataIF;
		port configIn : StatusIF;
		port cmdIn : CommandIF;
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

	// System Assembly
	part solararraysystem : SolarArraySystem {
		part missionbus : MissionBus;
		part powermodule : PowerModule;

		// Connections
		connection : link1 connect 
			missionbus.dataIn to powermodule.sensorOut;
		connection : link2 connect 
			powermodule.cmdIn to missionbus.dataIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by missionbus;
		satisfy requirement <'REQ-001'> by powermodule;
		satisfy requirement <'REQ-002'> by powermodule;
		satisfy requirement <'REQ-003'> by powermodule;
	}
}
