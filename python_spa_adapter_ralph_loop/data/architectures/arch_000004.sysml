package arch_000004 {
	// Satellite Bus Reference Architecture 4
	// Domain: satellite bus

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def SatelliteBusSystem {
	}

	part def DistributionUnit {
		port ctrlIn : DataIF;
		port sensorOut : PowerIF;
		port dataIn : TelemetryIF;
	}

	part def DataComputer {
		port dataIn : SignalIF;
		port sensorOut : DiagnosticIF;
		port statusOut : ThermalIF;
	}

	part def DataActuator {
		port dataOut : SignalIF;
		port statusOut : ControlIF;
		port ctrlIn : ConfigIF;
	}

	part def FlightController {
		port cmdOut : ThermalIF;
		port dataOut : DataIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The satellite bus system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The satellite bus system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part satellitebussystem : SatelliteBusSystem {
		part distributionunit : DistributionUnit;
		part datacomputer : DataComputer;
		part dataactuator : DataActuator;
		part flightcontroller : FlightController;

		// Connections
		connection : link1 connect 
			distributionunit.ctrlIn to flightcontroller.cmdOut;
		connection : link2 connect 
			datacomputer.dataIn to flightcontroller.cmdOut;
		connection : link3 connect 
			flightcontroller.dataOut to distributionunit.ctrlIn;
		connection : link4 connect 
			datacomputer.statusOut to distributionunit.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by flightcontroller;
		satisfy requirement <'REQ-001'> by distributionunit;
		satisfy requirement <'REQ-002'> by flightcontroller;
	}
}
