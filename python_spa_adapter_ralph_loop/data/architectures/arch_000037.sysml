package arch_000037 {
	// Attitude Control Reference Architecture 37
	// Domain: attitude control

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
	part def AttitudeControlSystem {
	}

	part def ProcessingInterface {
		port configIn : ControlIF;
		port ctrlIn : ConfigIF;
		port dataIn : DiagnosticIF;
	}

	part def CommandAssembly {
		port cmdOut : SignalIF;
	}

	part def SensorModule {
		port ctrlIn : ConfigIF;
		port statusOut : StatusIF;
	}

	part def FlightModule {
		port cmdOut : PowerIF;
		port pwrOut : DataIF;
		port ctrlIn : TelemetryIF;
	}

	part def DistributionProcessor {
		port sensorOut : ControlIF;
		port dataIn : ConfigIF;
		port telemetryOut : DiagnosticIF;
	}

	part def DataPayload {
		port dataIn : StatusIF;
	}

	part def MissionAssembly {
		port cmdIn : DataIF;
		port sensorOut : PowerIF;
		port pwrIn : PowerIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The attitude control system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The attitude control system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The attitude control system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The attitude control system shall maintain operational status monitoring. */
	}

	// System Assembly
	part attitudecontrolsystem : AttitudeControlSystem {
		part processinginterface : ProcessingInterface;
		part commandassembly : CommandAssembly;
		part sensormodule : SensorModule;
		part flightmodule : FlightModule;
		part distributionprocessor : DistributionProcessor;
		part datapayload : DataPayload;
		part missionassembly : MissionAssembly;

		// Connections
		connection : link1 connect 
			distributionprocessor.dataIn to flightmodule.pwrOut;
		connection : link2 connect 
			distributionprocessor.sensorOut to processinginterface.dataIn;
		connection : link3 connect 
			sensormodule.ctrlIn to distributionprocessor.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributionprocessor;
		satisfy requirement <'REQ-002'> by distributionprocessor;
		satisfy requirement <'REQ-003'> by commandassembly;
		satisfy requirement <'REQ-004'> by missionassembly;
		satisfy requirement <'REQ-004'> by distributionprocessor;
	}
}
