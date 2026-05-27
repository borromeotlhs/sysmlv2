package arch_000020 {
	// Thermal Control Reference Architecture 20
	// Domain: thermal control

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;

	// Part Definitions
	part def ThermalControlSystem {
	}

	part def CommandUnit {
		port sensorOut : CommandIF;
		port sensorOut : StatusIF;
	}

	part def NavBus {
		port dataOut : DataIF;
	}

	part def NavController {
		port cmdOut : PowerIF;
		port ctrlIn : SignalIF;
	}

	part def MissionInterface {
		port pwrIn : StatusIF;
		port ctrlIn : TelemetryIF;
		port dataOut : TelemetryIF;
	}

	part def ControlModule {
		port dataIn : StatusIF;
		port dataOut : DiagnosticIF;
		port sensorOut : PowerIF;
	}

	part def ProcessingProcessor {
		port pwrIn : StatusIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The thermal control system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The thermal control system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The thermal control system shall provide fault detection and recovery. */
	}

	// System Assembly
	part thermalcontrolsystem : ThermalControlSystem {
		part commandunit : CommandUnit;
		part navbus : NavBus;
		part navcontroller : NavController;
		part missioninterface : MissionInterface;
		part controlmodule : ControlModule;
		part processingprocessor : ProcessingProcessor;

		// Connections
		connection : link1 connect 
			controlmodule.dataIn to navcontroller.ctrlIn;
		connection : link2 connect 
			navcontroller.ctrlIn to processingprocessor.pwrIn;
		connection : link3 connect 
			controlmodule.sensorOut to missioninterface.dataOut;
		connection : link4 connect 
			missioninterface.dataOut to controlmodule.dataIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by controlmodule;
		satisfy requirement <'REQ-001'> by processingprocessor;
		satisfy requirement <'REQ-002'> by missioninterface;
		satisfy requirement <'REQ-002'> by navcontroller;
		satisfy requirement <'REQ-003'> by processingprocessor;
	}
}
