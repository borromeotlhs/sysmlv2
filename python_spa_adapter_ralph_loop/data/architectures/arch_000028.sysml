package arch_000028 {
	// Thermal Control Reference Architecture 28
	// Domain: thermal control

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;

	// Part Definitions
	part def ThermalControlSystem {
	}

	part def DistributionUnit {
		port cmdOut : ConfigIF;
	}

	part def ThermalAssembly {
		port statusOut : StatusIF;
	}

	part def MissionProcessor {
		port pwrOut : PowerIF;
		port pwrOut : SignalIF;
	}

	part def CommandActuator {
		port pwrOut : DiagnosticIF;
		port configIn : DataIF;
		port cmdIn : PowerIF;
	}

	part def MonitorSubsystem {
		port configIn : CommandIF;
	}

	part def FlightProcessor {
		port cmdOut : SignalIF;
		port ctrlIn : StatusIF;
		port ctrlIn : DiagnosticIF;
	}

	part def ProcessingInterface {
		port statusOut : SignalIF;
		port dataOut : ConfigIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The thermal control system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The thermal control system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The thermal control system shall provide fault detection and recovery. */
	}

	// System Assembly
	part thermalcontrolsystem : ThermalControlSystem {
		part distributionunit : DistributionUnit;
		part thermalassembly : ThermalAssembly;
		part missionprocessor : MissionProcessor;
		part commandactuator : CommandActuator;
		part monitorsubsystem : MonitorSubsystem;
		part flightprocessor : FlightProcessor;
		part processinginterface : ProcessingInterface;

		// Connections
		connection : link1 connect 
			thermalassembly.statusOut to commandactuator.pwrOut;
		connection : link2 connect 
			monitorsubsystem.configIn to flightprocessor.cmdOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by thermalassembly;
		satisfy requirement <'REQ-002'> by monitorsubsystem;
		satisfy requirement <'REQ-002'> by distributionunit;
		satisfy requirement <'REQ-003'> by thermalassembly;
	}
}
