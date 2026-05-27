package arch_000049 {
	// Propulsion Module Reference Architecture 49
	// Domain: propulsion module

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def PropulsionModuleSystem {
	}

	part def DataModule {
		port ctrlIn : ThermalIF;
		port configIn : ThermalIF;
		port statusOut : ThermalIF;
	}

	part def ProcessingController {
		port pwrOut : SignalIF;
		port statusOut : TelemetryIF;
		port sensorOut : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The propulsion module system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The propulsion module system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part propulsionmodulesystem : PropulsionModuleSystem {
		part datamodule : DataModule;
		part processingcontroller : ProcessingController;

		// Connections
		connection : link1 connect 
			processingcontroller.pwrOut to datamodule.ctrlIn;
		connection : link2 connect 
			processingcontroller.statusOut to datamodule.configIn;
		connection : link3 connect 
			processingcontroller.pwrOut to datamodule.statusOut;
		connection : link4 connect 
			datamodule.configIn to processingcontroller.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingcontroller;
		satisfy requirement <'REQ-001'> by datamodule;
		satisfy requirement <'REQ-002'> by processingcontroller;
		satisfy requirement <'REQ-002'> by datamodule;
	}
}
