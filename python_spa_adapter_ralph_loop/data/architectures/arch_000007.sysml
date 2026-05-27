package arch_000007 {
	// Lunar Habitat Reference Architecture 7
	// Domain: lunar habitat

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def LunarHabitatSystem {
	}

	part def MonitorActuator {
		port pwrIn : StatusIF;
	}

	part def ControlSensor {
		port telemetryOut : SignalIF;
	}

	part def ThermalUnit {
		port pwrOut : DataIF;
		port cmdIn : TelemetryIF;
	}

	part def DataInterface {
		port configIn : DataIF;
		port cmdOut : ConfigIF;
		port dataOut : ConfigIF;
	}

	part def ProcessingAssembly {
		port dataIn : ControlIF;
		port cmdOut : ThermalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The lunar habitat system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The lunar habitat system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part lunarhabitatsystem : LunarHabitatSystem {
		part monitoractuator : MonitorActuator;
		part controlsensor : ControlSensor;
		part thermalunit : ThermalUnit;
		part datainterface : DataInterface;
		part processingassembly : ProcessingAssembly;

		// Connections
		connection : link1 connect 
			datainterface.configIn to thermalunit.pwrOut;
		connection : link2 connect 
			processingassembly.cmdOut to datainterface.configIn;
		connection : link3 connect 
			processingassembly.cmdOut to monitoractuator.pwrIn;
		connection : link4 connect 
			controlsensor.telemetryOut to thermalunit.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingassembly;
		satisfy requirement <'REQ-002'> by thermalunit;
	}
}
