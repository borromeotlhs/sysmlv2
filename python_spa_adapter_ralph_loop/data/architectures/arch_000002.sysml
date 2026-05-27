package arch_000002 {
	// Avionics Bay Reference Architecture 2
	// Domain: avionics bay

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def AvionicsBaySystem {
	}

	part def ControlAssembly {
		port ctrlIn : ControlIF;
		port dataIn : ControlIF;
	}

	part def ControlModule {
		port dataOut : SignalIF;
		port telemetryOut : DataIF;
	}

	part def ProcessingController {
		port telemetryOut : PowerIF;
		port sensorOut : ThermalIF;
		port dataIn : TelemetryIF;
	}

	part def MissionInterface {
		port pwrIn : ConfigIF;
		port dataOut : ControlIF;
	}

	part def DataUnit {
		port dataOut : CommandIF;
	}

	part def FlightModule {
		port statusOut : SignalIF;
		port cmdOut : ThermalIF;
	}

	part def FlightSubsystem {
		port pwrOut : ThermalIF;
		port telemetryOut : TelemetryIF;
		port statusOut : TelemetryIF;
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

	// System Assembly
	part avionicsbaysystem : AvionicsBaySystem {
		part controlassembly : ControlAssembly;
		part controlmodule : ControlModule;
		part processingcontroller : ProcessingController;
		part missioninterface : MissionInterface;
		part dataunit : DataUnit;
		part flightmodule : FlightModule;
		part flightsubsystem : FlightSubsystem;

		// Connections
		connection : link1 connect 
			processingcontroller.telemetryOut to controlmodule.dataOut;
		connection : link2 connect 
			flightmodule.cmdOut to missioninterface.dataOut;
		connection : link3 connect 
			processingcontroller.telemetryOut to flightmodule.cmdOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingcontroller;
		satisfy requirement <'REQ-001'> by controlmodule;
		satisfy requirement <'REQ-002'> by dataunit;
		satisfy requirement <'REQ-003'> by controlassembly;
		satisfy requirement <'REQ-003'> by flightsubsystem;
	}
}
