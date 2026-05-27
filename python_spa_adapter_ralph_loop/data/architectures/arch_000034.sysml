package arch_000034 {
	// Power Distribution System Reference Architecture 34
	// Domain: power distribution system

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def ThermalIF;

	// Part Definitions
	part def PowerDistributionSystemSystem {
	}

	part def FlightComputer {
		port ctrlIn : DiagnosticIF;
	}

	part def DataSubsystem {
		port cmdIn : ConfigIF;
		port configIn : ThermalIF;
		port dataIn : SignalIF;
	}

	part def MonitorActuator {
		port cmdIn : DiagnosticIF;
		port pwrOut : ThermalIF;
	}

	part def NavController {
		port statusOut : PowerIF;
		port telemetryOut : DataIF;
		port sensorOut : ControlIF;
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
		part flightcomputer : FlightComputer;
		part datasubsystem : DataSubsystem;
		part monitoractuator : MonitorActuator;
		part navcontroller : NavController;

		// Connections
		connection : link1 connect 
			navcontroller.sensorOut to flightcomputer.ctrlIn;
		connection : link2 connect 
			navcontroller.telemetryOut to flightcomputer.ctrlIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by monitoractuator;
		satisfy requirement <'REQ-001'> by navcontroller;
		satisfy requirement <'REQ-002'> by monitoractuator;
		satisfy requirement <'REQ-003'> by monitoractuator;
	}
}
