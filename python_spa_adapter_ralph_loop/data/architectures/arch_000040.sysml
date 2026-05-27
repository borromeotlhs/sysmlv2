package arch_000040 {
	// Robotic Arm Reference Architecture 40
	// Domain: robotic arm

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ControlIF;
	interface def DataIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def RoboticArmSystem {
	}

	part def FlightSubsystem {
		port configIn : DataIF;
		port dataIn : DataIF;
		port statusOut : ControlIF;
	}

	part def SensorPayload {
		port sensorOut : ControlIF;
		port dataIn : ThermalIF;
	}

	part def DistributionSensor {
		port sensorOut : StatusIF;
		port sensorOut : CommandIF;
		port cmdIn : CommandIF;
	}

	part def PowerActuator {
		port pwrOut : TelemetryIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The robotic arm system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The robotic arm system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The robotic arm system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The robotic arm system shall maintain operational status monitoring. */
	}

	// System Assembly
	part roboticarmsystem : RoboticArmSystem {
		part flightsubsystem : FlightSubsystem;
		part sensorpayload : SensorPayload;
		part distributionsensor : DistributionSensor;
		part poweractuator : PowerActuator;

		// Connections
		connection : link1 connect 
			flightsubsystem.statusOut to poweractuator.pwrOut;
		connection : link2 connect 
			flightsubsystem.statusOut to distributionsensor.sensorOut;
		connection : link3 connect 
			sensorpayload.dataIn to distributionsensor.sensorOut;
		connection : link4 connect 
			distributionsensor.cmdIn to sensorpayload.dataIn;
		connection : link5 connect 
			flightsubsystem.configIn to distributionsensor.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by poweractuator;
		satisfy requirement <'REQ-002'> by flightsubsystem;
		satisfy requirement <'REQ-002'> by distributionsensor;
		satisfy requirement <'REQ-003'> by distributionsensor;
		satisfy requirement <'REQ-003'> by poweractuator;
		satisfy requirement <'REQ-004'> by flightsubsystem;
	}
}
