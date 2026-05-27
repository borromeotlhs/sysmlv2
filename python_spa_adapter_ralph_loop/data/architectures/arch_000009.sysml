package arch_000009 {
	// Reaction Wheel Reference Architecture 9
	// Domain: reaction wheel

	import ScalarValues::*;

	// Interface Definitions
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def ReactionWheelSystem {
	}

	part def DistributionSubsystem {
		port cmdOut : StatusIF;
		port cmdIn : TelemetryIF;
		port dataOut : ThermalIF;
	}

	part def DistributionInterface {
		port pwrOut : SignalIF;
		port dataOut : ThermalIF;
	}

	part def ProcessingModule {
		port telemetryOut : ThermalIF;
	}

	part def PowerProcessor {
		port pwrOut : SignalIF;
		port cmdOut : SignalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The reaction wheel system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The reaction wheel system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part reactionwheelsystem : ReactionWheelSystem {
		part distributionsubsystem : DistributionSubsystem;
		part distributioninterface : DistributionInterface;
		part processingmodule : ProcessingModule;
		part powerprocessor : PowerProcessor;

		// Connections
		connection : link1 connect 
			powerprocessor.pwrOut to processingmodule.telemetryOut;
		connection : link2 connect 
			distributionsubsystem.cmdIn to distributioninterface.dataOut;
		connection : link3 connect 
			distributioninterface.dataOut to distributionsubsystem.cmdOut;
		connection : link4 connect 
			distributionsubsystem.cmdIn to powerprocessor.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributionsubsystem;
		satisfy requirement <'REQ-001'> by processingmodule;
		satisfy requirement <'REQ-002'> by distributionsubsystem;
		satisfy requirement <'REQ-002'> by processingmodule;
	}
}
