package arch_000043 {
	// Solar Array Reference Architecture 43
	// Domain: solar array

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def ControlIF;
	interface def DiagnosticIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def SolarArraySystem {
	}

	part def NavInterface {
		port configIn : ThermalIF;
		port sensorOut : CommandIF;
		port dataIn : StatusIF;
	}

	part def DataUnit {
		port cmdIn : StatusIF;
	}

	part def ThermalUnit {
		port dataIn : SignalIF;
		port cmdIn : CommandIF;
	}

	part def MonitorComputer {
		port configIn : DiagnosticIF;
		port cmdOut : ControlIF;
	}

	part def DistributionController {
		port ctrlIn : ConfigIF;
		port sensorOut : TelemetryIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The solar array system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The solar array system shall trace subsystem design to requirements. */
	}

	requirement <'REQ-003'> {
		doc /* The solar array system shall provide fault detection and recovery. */
	}

	// System Assembly
	part solararraysystem : SolarArraySystem {
		part navinterface : NavInterface;
		part dataunit : DataUnit;
		part thermalunit : ThermalUnit;
		part monitorcomputer : MonitorComputer;
		part distributioncontroller : DistributionController;

		// Connections
		connection : link1 connect 
			distributioncontroller.ctrlIn to monitorcomputer.cmdOut;
		connection : link2 connect 
			dataunit.cmdIn to navinterface.sensorOut;
		connection : link3 connect 
			navinterface.dataIn to monitorcomputer.cmdOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by navinterface;
		satisfy requirement <'REQ-002'> by thermalunit;
		satisfy requirement <'REQ-002'> by dataunit;
		satisfy requirement <'REQ-003'> by distributioncontroller;
	}
}
