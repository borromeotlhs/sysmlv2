package arch_000015 {
	// Sensor Suite Reference Architecture 15
	// Domain: sensor suite

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;

	// Part Definitions
	part def SensorSuiteSystem {
	}

	part def CommInterface {
		port telemetryOut : TelemetryIF;
		port dataIn : StatusIF;
	}

	part def ThermalController {
		port sensorOut : SignalIF;
	}

	part def SensorInterface {
		port sensorOut : TelemetryIF;
		port ctrlIn : StatusIF;
		port configIn : SignalIF;
	}

	part def ThermalComputer {
		port dataOut : DataIF;
		port pwrIn : TelemetryIF;
	}

	part def CommPayload {
		port ctrlIn : DiagnosticIF;
	}

	part def FlightSubsystem {
		port telemetryOut : StatusIF;
		port pwrOut : CommandIF;
		port ctrlIn : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The sensor suite system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The sensor suite system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part sensorsuitesystem : SensorSuiteSystem {
		part comminterface : CommInterface;
		part thermalcontroller : ThermalController;
		part sensorinterface : SensorInterface;
		part thermalcomputer : ThermalComputer;
		part commpayload : CommPayload;
		part flightsubsystem : FlightSubsystem;

		// Connections
		connection : link1 connect 
			thermalcomputer.pwrIn to sensorinterface.sensorOut;
		connection : link2 connect 
			sensorinterface.ctrlIn to flightsubsystem.telemetryOut;
		connection : link3 connect 
			commpayload.ctrlIn to comminterface.telemetryOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by thermalcontroller;
		satisfy requirement <'REQ-002'> by thermalcomputer;
		satisfy requirement <'REQ-002'> by commpayload;
	}
}
