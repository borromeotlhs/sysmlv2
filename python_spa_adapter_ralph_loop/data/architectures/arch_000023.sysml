package arch_000023 {
	// Avionics Bay Reference Architecture 23
	// Domain: avionics bay

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def SignalIF;

	// Part Definitions
	part def AvionicsBaySystem {
	}

	part def CommUnit {
		port configIn : SignalIF;
	}

	part def MissionActuator {
		port telemetryOut : PowerIF;
		port telemetryOut : DataIF;
		port telemetryOut : CommandIF;
	}

	part def MonitorBus {
		port ctrlIn : CommandIF;
		port configIn : ControlIF;
	}

	part def ProcessingPayload {
		port dataIn : DataIF;
		port pwrIn : ControlIF;
		port statusOut : PowerIF;
	}

	part def PowerModule {
		port dataIn : ConfigIF;
	}

	part def ControlAssembly {
		port sensorOut : ConfigIF;
		port pwrIn : PowerIF;
	}

	part def DataInterface {
		port ctrlIn : SignalIF;
		port pwrOut : DataIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The avionics bay system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The avionics bay system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The avionics bay system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The avionics bay system shall maintain operational status monitoring. */
	}

	// System Assembly
	part avionicsbaysystem : AvionicsBaySystem {
		part communit : CommUnit;
		part missionactuator : MissionActuator;
		part monitorbus : MonitorBus;
		part processingpayload : ProcessingPayload;
		part powermodule : PowerModule;
		part controlassembly : ControlAssembly;
		part datainterface : DataInterface;

		// Connections
		connection : link1 connect 
			datainterface.ctrlIn to missionactuator.telemetryOut;
		connection : link2 connect 
			processingpayload.dataIn to datainterface.pwrOut;
		connection : link3 connect 
			monitorbus.configIn to missionactuator.telemetryOut;
		connection : link4 connect 
			communit.configIn to monitorbus.ctrlIn;
		connection : link5 connect 
			missionactuator.telemetryOut to processingpayload.pwrIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by powermodule;
		satisfy requirement <'REQ-001'> by processingpayload;
		satisfy requirement <'REQ-002'> by communit;
		satisfy requirement <'REQ-002'> by controlassembly;
		satisfy requirement <'REQ-003'> by processingpayload;
		satisfy requirement <'REQ-004'> by powermodule;
	}
}
