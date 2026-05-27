package arch_000019 {
	// Life Support Reference Architecture 19
	// Domain: life support

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def StatusIF;
	interface def TelemetryIF;

	// Part Definitions
	part def LifeSupportSystem {
	}

	part def MissionController {
		port configIn : CommandIF;
		port dataIn : TelemetryIF;
	}

	part def DataInterface {
		port telemetryOut : TelemetryIF;
		port pwrIn : PowerIF;
		port configIn : StatusIF;
	}

	part def ControlActuator {
		port ctrlIn : DataIF;
		port ctrlIn : ControlIF;
		port statusOut : ControlIF;
	}

	part def MissionInterface {
		port telemetryOut : DataIF;
		port dataIn : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The life support system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The life support system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The life support system shall provide fault detection and recovery. */
	}

	// System Assembly
	part lifesupportsystem : LifeSupportSystem {
		part missioncontroller : MissionController;
		part datainterface : DataInterface;
		part controlactuator : ControlActuator;
		part missioninterface : MissionInterface;

		// Connections
		connection : link1 connect 
			controlactuator.statusOut to datainterface.configIn;
		connection : link2 connect 
			controlactuator.ctrlIn to missioninterface.telemetryOut;
		connection : link3 connect 
			controlactuator.statusOut to missioncontroller.dataIn;
		connection : link4 connect 
			datainterface.configIn to controlactuator.ctrlIn;
		connection : link5 connect 
			missioncontroller.configIn to missioninterface.telemetryOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by datainterface;
		satisfy requirement <'REQ-002'> by missioninterface;
		satisfy requirement <'REQ-002'> by controlactuator;
		satisfy requirement <'REQ-003'> by missioncontroller;
		satisfy requirement <'REQ-003'> by missioninterface;
	}
}
