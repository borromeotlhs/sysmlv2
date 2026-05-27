package arch_000047 {
	// Power Distribution System Reference Architecture 47
	// Domain: power distribution system

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def DiagnosticIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def PowerDistributionSystemSystem {
	}

	part def ThermalProcessor {
		port dataOut : ThermalIF;
	}

	part def PowerModule {
		port cmdOut : DiagnosticIF;
	}

	part def ProcessingController {
		port ctrlIn : DiagnosticIF;
	}

	part def MissionInterface {
		port cmdIn : ThermalIF;
		port cmdIn : StatusIF;
		port ctrlIn : ThermalIF;
	}

	part def CommActuator {
		port dataOut : CommandIF;
		port dataIn : ConfigIF;
		port pwrIn : ThermalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The power distribution system system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The power distribution system system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The power distribution system system shall provide fault detection and recovery. */
	}

	// System Assembly
	part powerdistributionsystemsystem : PowerDistributionSystemSystem {
		part thermalprocessor : ThermalProcessor;
		part powermodule : PowerModule;
		part processingcontroller : ProcessingController;
		part missioninterface : MissionInterface;
		part commactuator : CommActuator;

		// Connections
		connection : link1 connect 
			missioninterface.cmdIn to processingcontroller.ctrlIn;
		connection : link2 connect 
			commactuator.pwrIn to missioninterface.cmdIn;
		connection : link3 connect 
			thermalprocessor.dataOut to commactuator.pwrIn;
		connection : link4 connect 
			processingcontroller.ctrlIn to commactuator.dataOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingcontroller;
		satisfy requirement <'REQ-002'> by commactuator;
		satisfy requirement <'REQ-002'> by processingcontroller;
		satisfy requirement <'REQ-003'> by missioninterface;
		satisfy requirement <'REQ-003'> by powermodule;
	}
}
