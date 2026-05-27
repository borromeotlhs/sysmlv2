package arch_000013 {
	// Command Data Handling Reference Architecture 13
	// Domain: command data handling

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def StatusIF;

	// Part Definitions
	part def CommandDataHandlingSystem {
	}

	part def MonitorInterface {
		port sensorOut : CommandIF;
		port statusOut : DiagnosticIF;
		port configIn : CommandIF;
	}

	part def DistributionSubsystem {
		port telemetryOut : StatusIF;
	}

	part def ProcessingProcessor {
		port ctrlIn : PowerIF;
	}

	part def NavProcessor {
		port pwrIn : StatusIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The command data handling system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The command data handling system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The command data handling system shall provide fault detection and recovery. */
	}

	// System Assembly
	part commanddatahandlingsystem : CommandDataHandlingSystem {
		part monitorinterface : MonitorInterface;
		part distributionsubsystem : DistributionSubsystem;
		part processingprocessor : ProcessingProcessor;
		part navprocessor : NavProcessor;

		// Connections
		connection : link1 connect 
			monitorinterface.statusOut to distributionsubsystem.telemetryOut;
		connection : link2 connect 
			monitorinterface.configIn to distributionsubsystem.telemetryOut;
		connection : link3 connect 
			monitorinterface.sensorOut to distributionsubsystem.telemetryOut;
		connection : link4 connect 
			navprocessor.pwrIn to processingprocessor.ctrlIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by monitorinterface;
		satisfy requirement <'REQ-002'> by monitorinterface;
		satisfy requirement <'REQ-003'> by distributionsubsystem;
	}
}
