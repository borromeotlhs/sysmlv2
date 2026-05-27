package arch_000022 {
	// Sensor Suite Reference Architecture 22
	// Domain: sensor suite

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def SensorSuiteSystem {
	}

	part def CommProcessor {
		port dataIn : DataIF;
	}

	part def DataSensor {
		port statusOut : DiagnosticIF;
		port telemetryOut : ThermalIF;
		port ctrlIn : DiagnosticIF;
	}

	part def CommActuator {
		port dataOut : TelemetryIF;
	}

	part def MonitorProcessor {
		port pwrIn : TelemetryIF;
		port pwrIn : CommandIF;
		port ctrlIn : SignalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The sensor suite system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The sensor suite system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The sensor suite system shall provide fault detection and recovery. */
	}

	// System Assembly
	part sensorsuitesystem : SensorSuiteSystem {
		part commprocessor : CommProcessor;
		part datasensor : DataSensor;
		part commactuator : CommActuator;
		part monitorprocessor : MonitorProcessor;

		// Connections
		connection : link1 connect 
			datasensor.statusOut to monitorprocessor.ctrlIn;
		connection : link2 connect 
			commactuator.dataOut to monitorprocessor.pwrIn;
		connection : link3 connect 
			monitorprocessor.ctrlIn to commactuator.dataOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by commprocessor;
		satisfy requirement <'REQ-001'> by monitorprocessor;
		satisfy requirement <'REQ-002'> by commactuator;
		satisfy requirement <'REQ-002'> by monitorprocessor;
		satisfy requirement <'REQ-003'> by commactuator;
		satisfy requirement <'REQ-003'> by commprocessor;
	}
}
