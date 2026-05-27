package arch_000005 {
	// Power Distribution System Reference Architecture 5
	// Domain: power distribution system

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def DataIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def PowerDistributionSystemSystem {
	}

	part def DistributionSubsystem {
		port cmdIn : DataIF;
		port cmdIn : StatusIF;
	}

	part def DataController {
		port pwrOut : DataIF;
		port dataOut : ThermalIF;
		port dataOut : ConfigIF;
	}

	part def FlightInterface {
		port dataIn : StatusIF;
		port dataIn : SignalIF;
	}

	part def CommAssembly {
		port dataOut : DataIF;
		port ctrlIn : ConfigIF;
	}

	part def CommSubsystem {
		port cmdIn : ConfigIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The power distribution system system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The power distribution system system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part powerdistributionsystemsystem : PowerDistributionSystemSystem {
		part distributionsubsystem : DistributionSubsystem;
		part datacontroller : DataController;
		part flightinterface : FlightInterface;
		part commassembly : CommAssembly;
		part commsubsystem : CommSubsystem;

		// Connections
		connection : link1 connect 
			distributionsubsystem.cmdIn to datacontroller.dataOut;
		connection : link2 connect 
			flightinterface.dataIn to commassembly.dataOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributionsubsystem;
		satisfy requirement <'REQ-001'> by datacontroller;
		satisfy requirement <'REQ-002'> by distributionsubsystem;
		satisfy requirement <'REQ-002'> by commassembly;
	}
}
