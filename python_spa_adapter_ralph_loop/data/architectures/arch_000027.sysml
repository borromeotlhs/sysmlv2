package arch_000027 {
	// Telemetry System Reference Architecture 27
	// Domain: telemetry system

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;

	// Part Definitions
	part def TelemetrySystemSystem {
	}

	part def DataSubsystem {
		port telemetryOut : SignalIF;
		port pwrOut : PowerIF;
	}

	part def ThermalPayload {
		port ctrlIn : DataIF;
		port cmdOut : DataIF;
		port cmdOut : StatusIF;
	}

	part def CommSubsystem {
		port pwrOut : PowerIF;
	}

	part def ProcessingController {
		port cmdIn : DiagnosticIF;
		port sensorOut : ConfigIF;
		port pwrOut : DataIF;
	}

	part def ThermalSubsystem {
		port pwrOut : StatusIF;
		port cmdIn : SignalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The telemetry system system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The telemetry system system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The telemetry system system shall provide fault detection and recovery. */
	}

	// System Assembly
	part telemetrysystemsystem : TelemetrySystemSystem {
		part datasubsystem : DataSubsystem;
		part thermalpayload : ThermalPayload;
		part commsubsystem : CommSubsystem;
		part processingcontroller : ProcessingController;
		part thermalsubsystem : ThermalSubsystem;

		// Connections
		connection : link1 connect 
			commsubsystem.pwrOut to datasubsystem.pwrOut;
		connection : link2 connect 
			processingcontroller.pwrOut to thermalpayload.cmdOut;
		connection : link3 connect 
			thermalsubsystem.cmdIn to processingcontroller.sensorOut;
		connection : link4 connect 
			processingcontroller.pwrOut to commsubsystem.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingcontroller;
		satisfy requirement <'REQ-002'> by thermalsubsystem;
		satisfy requirement <'REQ-003'> by datasubsystem;
		satisfy requirement <'REQ-003'> by thermalpayload;
	}
}
