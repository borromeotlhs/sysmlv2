package arch_000050 {
	// Communication Relay Reference Architecture 50
	// Domain: communication relay

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def CommunicationRelaySystem {
	}

	part def DistributionAssembly {
		port cmdIn : CommandIF;
		port statusOut : PowerIF;
		port telemetryOut : ThermalIF;
	}

	part def CommandProcessor {
		port dataIn : CommandIF;
	}

	part def ProcessingSensor {
		port sensorOut : TelemetryIF;
	}

	part def NavProcessor {
		port cmdIn : DiagnosticIF;
		port telemetryOut : DiagnosticIF;
	}

	part def SensorInterface {
		port telemetryOut : TelemetryIF;
		port cmdIn : CommandIF;
	}

	part def MissionSensor {
		port sensorOut : StatusIF;
		port cmdIn : CommandIF;
		port sensorOut : SignalIF;
	}

	part def MissionController {
		port pwrIn : CommandIF;
		port sensorOut : StatusIF;
		port dataIn : DataIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The communication relay system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The communication relay system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The communication relay system shall provide fault detection and recovery. */
	}

	// System Assembly
	part communicationrelaysystem : CommunicationRelaySystem {
		part distributionassembly : DistributionAssembly;
		part commandprocessor : CommandProcessor;
		part processingsensor : ProcessingSensor;
		part navprocessor : NavProcessor;
		part sensorinterface : SensorInterface;
		part missionsensor : MissionSensor;
		part missioncontroller : MissionController;

		// Connections
		connection : link1 connect 
			sensorinterface.cmdIn to distributionassembly.telemetryOut;
		connection : link2 connect 
			commandprocessor.dataIn to missionsensor.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingsensor;
		satisfy requirement <'REQ-001'> by navprocessor;
		satisfy requirement <'REQ-002'> by processingsensor;
		satisfy requirement <'REQ-003'> by navprocessor;
		satisfy requirement <'REQ-003'> by sensorinterface;
	}
}
