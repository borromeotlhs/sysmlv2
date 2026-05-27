package arch_000044 {
	// Instrument Platform Reference Architecture 44
	// Domain: instrument platform

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def InstrumentPlatformSystem {
	}

	part def CommSubsystem {
		port statusOut : ThermalIF;
		port ctrlIn : SignalIF;
	}

	part def SensorAssembly {
		port pwrIn : DiagnosticIF;
		port configIn : CommandIF;
	}

	part def FlightSubsystem {
		port telemetryOut : ControlIF;
		port dataOut : CommandIF;
	}

	part def MonitorController {
		port cmdOut : TelemetryIF;
		port pwrIn : PowerIF;
		port statusOut : ConfigIF;
	}

	part def CommandProcessor {
		port pwrIn : DataIF;
		port telemetryOut : SignalIF;
		port pwrOut : DiagnosticIF;
	}

	part def NavAssembly {
		port dataOut : PowerIF;
	}

	part def DataComputer {
		port dataIn : TelemetryIF;
		port configIn : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The instrument platform system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The instrument platform system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The instrument platform system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The instrument platform system shall maintain operational status monitoring. */
	}

	// System Assembly
	part instrumentplatformsystem : InstrumentPlatformSystem {
		part commsubsystem : CommSubsystem;
		part sensorassembly : SensorAssembly;
		part flightsubsystem : FlightSubsystem;
		part monitorcontroller : MonitorController;
		part commandprocessor : CommandProcessor;
		part navassembly : NavAssembly;
		part datacomputer : DataComputer;

		// Connections
		connection : link1 connect 
			commandprocessor.pwrOut to monitorcontroller.statusOut;
		connection : link2 connect 
			navassembly.dataOut to monitorcontroller.statusOut;
		connection : link3 connect 
			datacomputer.dataIn to sensorassembly.configIn;
		connection : link4 connect 
			commandprocessor.telemetryOut to navassembly.dataOut;
		connection : link5 connect 
			datacomputer.dataIn to navassembly.dataOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by commandprocessor;
		satisfy requirement <'REQ-001'> by navassembly;
		satisfy requirement <'REQ-002'> by commsubsystem;
		satisfy requirement <'REQ-002'> by commandprocessor;
		satisfy requirement <'REQ-003'> by commsubsystem;
		satisfy requirement <'REQ-004'> by commandprocessor;
	}
}
