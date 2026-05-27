package arch_000035 {
	// Power Distribution System Reference Architecture 35
	// Domain: power distribution system

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def PowerDistributionSystemSystem {
	}

	part def MonitorInterface {
		port ctrlIn : PowerIF;
		port dataIn : DataIF;
	}

	part def FlightActuator {
		port ctrlIn : CommandIF;
		port pwrIn : ThermalIF;
		port cmdIn : ThermalIF;
	}

	part def ProcessingAssembly {
		port pwrOut : SignalIF;
	}

	part def CommandComputer {
		port statusOut : ConfigIF;
		port ctrlIn : SignalIF;
		port cmdIn : ThermalIF;
	}

	part def ThermalSensor {
		port pwrOut : CommandIF;
		port telemetryOut : ControlIF;
	}

	part def ThermalInterface {
		port cmdOut : ControlIF;
		port statusOut : StatusIF;
	}

	part def CommandInterface {
		port ctrlIn : StatusIF;
		port pwrOut : PowerIF;
		port ctrlIn : TelemetryIF;
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

	requirement <'REQ-004'> {
		doc /* The power distribution system system shall maintain operational status monitoring. */
	}

	// System Assembly
	part powerdistributionsystemsystem : PowerDistributionSystemSystem {
		part monitorinterface : MonitorInterface;
		part flightactuator : FlightActuator;
		part processingassembly : ProcessingAssembly;
		part commandcomputer : CommandComputer;
		part thermalsensor : ThermalSensor;
		part thermalinterface : ThermalInterface;
		part commandinterface : CommandInterface;

		// Connections
		connection : link1 connect 
			commandcomputer.cmdIn to flightactuator.ctrlIn;
		connection : link2 connect 
			flightactuator.ctrlIn to commandinterface.ctrlIn;
		connection : link3 connect 
			processingassembly.pwrOut to thermalsensor.pwrOut;
		connection : link4 connect 
			thermalsensor.pwrOut to commandinterface.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by flightactuator;
		satisfy requirement <'REQ-001'> by thermalinterface;
		satisfy requirement <'REQ-002'> by processingassembly;
		satisfy requirement <'REQ-002'> by commandcomputer;
		satisfy requirement <'REQ-003'> by thermalinterface;
		satisfy requirement <'REQ-004'> by thermalsensor;
		satisfy requirement <'REQ-004'> by commandcomputer;
	}
}
