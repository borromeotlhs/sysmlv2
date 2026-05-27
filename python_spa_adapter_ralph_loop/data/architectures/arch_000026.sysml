package arch_000026 {
	// Uav Payload Reference Architecture 26
	// Domain: uav payload

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def DataIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def UavPayloadSystem {
	}

	part def DistributionModule {
		port statusOut : ConfigIF;
	}

	part def ControlAssembly {
		port cmdOut : TelemetryIF;
	}

	part def MissionProcessor {
		port pwrOut : ConfigIF;
		port configIn : DataIF;
	}

	part def PowerComputer {
		port sensorOut : ThermalIF;
		port configIn : CommandIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The uav payload system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The uav payload system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The uav payload system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The uav payload system shall maintain operational status monitoring. */
	}

	// System Assembly
	part uavpayloadsystem : UavPayloadSystem {
		part distributionmodule : DistributionModule;
		part controlassembly : ControlAssembly;
		part missionprocessor : MissionProcessor;
		part powercomputer : PowerComputer;

		// Connections
		connection : link1 connect 
			missionprocessor.configIn to powercomputer.configIn;
		connection : link2 connect 
			distributionmodule.statusOut to missionprocessor.configIn;
		connection : link3 connect 
			missionprocessor.pwrOut to powercomputer.sensorOut;
		connection : link4 connect 
			distributionmodule.statusOut to controlassembly.cmdOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by powercomputer;
		satisfy requirement <'REQ-001'> by missionprocessor;
		satisfy requirement <'REQ-002'> by powercomputer;
		satisfy requirement <'REQ-002'> by missionprocessor;
		satisfy requirement <'REQ-003'> by distributionmodule;
		satisfy requirement <'REQ-003'> by missionprocessor;
		satisfy requirement <'REQ-004'> by controlassembly;
	}
}
