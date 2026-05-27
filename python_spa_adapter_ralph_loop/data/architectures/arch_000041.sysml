package arch_000041 {
	// Docking Mechanism Reference Architecture 41
	// Domain: docking mechanism

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DiagnosticIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def DockingMechanismSystem {
	}

	part def CommandSensor {
		port cmdOut : ThermalIF;
		port cmdIn : TelemetryIF;
		port pwrOut : StatusIF;
	}

	part def MonitorBus {
		port statusOut : ThermalIF;
	}

	part def ControlSubsystem {
		port sensorOut : DiagnosticIF;
		port ctrlIn : CommandIF;
	}

	part def CommandInterface {
		port dataIn : ConfigIF;
		port dataOut : ConfigIF;
		port pwrOut : TelemetryIF;
	}

	part def DataComputer {
		port statusOut : ControlIF;
		port dataIn : TelemetryIF;
		port sensorOut : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The docking mechanism system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The docking mechanism system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The docking mechanism system shall provide fault detection and recovery. */
	}

	requirement <'REQ-004'> {
		doc /* The docking mechanism system shall maintain operational status monitoring. */
	}

	// System Assembly
	part dockingmechanismsystem : DockingMechanismSystem {
		part commandsensor : CommandSensor;
		part monitorbus : MonitorBus;
		part controlsubsystem : ControlSubsystem;
		part commandinterface : CommandInterface;
		part datacomputer : DataComputer;

		// Connections
		connection : link1 connect 
			datacomputer.sensorOut to controlsubsystem.sensorOut;
		connection : link2 connect 
			commandinterface.dataOut to monitorbus.statusOut;
		connection : link3 connect 
			controlsubsystem.sensorOut to commandinterface.pwrOut;
		connection : link4 connect 
			monitorbus.statusOut to controlsubsystem.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by commandinterface;
		satisfy requirement <'REQ-002'> by commandinterface;
		satisfy requirement <'REQ-002'> by controlsubsystem;
		satisfy requirement <'REQ-003'> by controlsubsystem;
		satisfy requirement <'REQ-003'> by commandsensor;
		satisfy requirement <'REQ-004'> by commandinterface;
		satisfy requirement <'REQ-004'> by controlsubsystem;
	}
}
