package arch_000008 {
	// Propulsion Module Reference Architecture 8
	// Domain: propulsion module

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def SignalIF;

	// Part Definitions
	part def PropulsionModuleSystem {
	}

	part def DataBus {
		port statusOut : SignalIF;
		port cmdIn : CommandIF;
		port pwrOut : PowerIF;
	}

	part def ThermalModule {
		port pwrIn : PowerIF;
		port ctrlIn : ConfigIF;
		port statusOut : ConfigIF;
	}

	part def MonitorInterface {
		port cmdOut : DataIF;
	}

	part def PowerSensor {
		port dataIn : ConfigIF;
		port cmdIn : ControlIF;
		port configIn : ConfigIF;
	}

	part def NavUnit {
		port statusOut : PowerIF;
	}

	part def MissionController {
		port pwrIn : ControlIF;
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
		part databus : DataBus;
		part thermalmodule : ThermalModule;
		part monitorinterface : MonitorInterface;
		part powersensor : PowerSensor;
		part navunit : NavUnit;
		part missioncontroller : MissionController;

		// Connections
		connection : link1 connect 
			navunit.statusOut to thermalmodule.pwrIn;
		connection : link2 connect 
			databus.cmdIn to thermalmodule.statusOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by thermalmodule;
		satisfy requirement <'REQ-002'> by thermalmodule;
		satisfy requirement <'REQ-003'> by databus;
		satisfy requirement <'REQ-003'> by thermalmodule;
	}
}
