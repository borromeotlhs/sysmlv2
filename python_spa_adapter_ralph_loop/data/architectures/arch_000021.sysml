package arch_000021 {
	// Power Distribution System Reference Architecture 21
	// Domain: power distribution system

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;

	// Part Definitions
	part def PowerDistributionSystemSystem {
	}

	part def CommModule {
		port dataIn : TelemetryIF;
		port cmdIn : PowerIF;
		port sensorOut : DiagnosticIF;
	}

	part def DistributionSubsystem {
		port cmdOut : TelemetryIF;
		port cmdOut : ConfigIF;
	}

	part def MissionAssembly {
		port cmdIn : PowerIF;
		port statusOut : PowerIF;
	}

	part def ProcessingPayload {
		port ctrlIn : SignalIF;
	}

	part def ProcessingSubsystem {
		port configIn : StatusIF;
		port telemetryOut : DataIF;
	}

	part def CommInterface {
		port telemetryOut : ConfigIF;
		port statusOut : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The power distribution system system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The power distribution system system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The power distribution system system shall provide fault detection and recovery. */
	}

	// System Assembly
	part powerdistributionsystemsystem : PowerDistributionSystemSystem {
		part commmodule : CommModule;
		part distributionsubsystem : DistributionSubsystem;
		part missionassembly : MissionAssembly;
		part processingpayload : ProcessingPayload;
		part processingsubsystem : ProcessingSubsystem;
		part comminterface : CommInterface;

		// Connections
		connection : link1 connect 
			processingsubsystem.configIn to commmodule.dataIn;
		connection : link2 connect 
			commmodule.cmdIn to distributionsubsystem.cmdOut;
		connection : link3 connect 
			comminterface.telemetryOut to distributionsubsystem.cmdOut;
		connection : link4 connect 
			comminterface.statusOut to commmodule.cmdIn;
		connection : link5 connect 
			commmodule.cmdIn to comminterface.telemetryOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by comminterface;
		satisfy requirement <'REQ-002'> by commmodule;
		satisfy requirement <'REQ-002'> by comminterface;
		satisfy requirement <'REQ-003'> by commmodule;
		satisfy requirement <'REQ-003'> by missionassembly;
	}
}
