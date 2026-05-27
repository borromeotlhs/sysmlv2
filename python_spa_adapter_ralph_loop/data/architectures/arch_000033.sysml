package arch_000033 {
	// Antenna Subsystem Reference Architecture 33
	// Domain: antenna subsystem

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def AntennaSubsystemSystem {
	}

	part def DistributionUnit {
		port pwrIn : CommandIF;
	}

	part def DistributionSubsystem {
		port ctrlIn : ControlIF;
		port sensorOut : DataIF;
		port sensorOut : DataIF;
	}

	part def SensorSensor {
		port cmdOut : PowerIF;
		port pwrIn : TelemetryIF;
	}

	part def CommProcessor {
		port dataIn : StatusIF;
		port cmdOut : ThermalIF;
		port ctrlIn : ControlIF;
	}

	part def DataActuator {
		port statusOut : CommandIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The antenna subsystem system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The antenna subsystem system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The antenna subsystem system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The antenna subsystem system shall maintain operational status monitoring. */
	}

	// System Assembly
	part antennasubsystemsystem : AntennaSubsystemSystem {
		part distributionunit : DistributionUnit;
		part distributionsubsystem : DistributionSubsystem;
		part sensorsensor : SensorSensor;
		part commprocessor : CommProcessor;
		part dataactuator : DataActuator;

		// Connections
		connection : link1 connect 
			commprocessor.ctrlIn to sensorsensor.pwrIn;
		connection : link2 connect 
			commprocessor.dataIn to distributionsubsystem.ctrlIn;
		connection : link3 connect 
			distributionsubsystem.sensorOut to distributionunit.pwrIn;
		connection : link4 connect 
			distributionsubsystem.ctrlIn to sensorsensor.pwrIn;
		connection : link5 connect 
			sensorsensor.cmdOut to commprocessor.cmdOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by commprocessor;
		satisfy requirement <'REQ-001'> by distributionunit;
		satisfy requirement <'REQ-002'> by distributionunit;
		satisfy requirement <'REQ-003'> by distributionsubsystem;
		satisfy requirement <'REQ-003'> by dataactuator;
		satisfy requirement <'REQ-004'> by distributionunit;
		satisfy requirement <'REQ-004'> by sensorsensor;
	}
}
