package arch_000006 {
	// Thermal Control Reference Architecture 6
	// Domain: thermal control

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ConfigIF;
	interface def PowerIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def ThermalControlSystem {
	}

	part def PowerSubsystem {
		port pwrIn : ThermalIF;
	}

	part def ProcessingBus {
		port configIn : ConfigIF;
	}

	part def DistributionSensor {
		port pwrOut : CommandIF;
	}

	part def MonitorBus {
		port configIn : TelemetryIF;
	}

	part def NavProcessor {
		port sensorOut : PowerIF;
		port cmdIn : ConfigIF;
		port cmdOut : PowerIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The thermal control system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The thermal control system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part thermalcontrolsystem : ThermalControlSystem {
		part powersubsystem : PowerSubsystem;
		part processingbus : ProcessingBus;
		part distributionsensor : DistributionSensor;
		part monitorbus : MonitorBus;
		part navprocessor : NavProcessor;

		// Connections
		connection : link1 connect 
			navprocessor.sensorOut to powersubsystem.pwrIn;
		connection : link2 connect 
			navprocessor.cmdOut to processingbus.configIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by navprocessor;
		satisfy requirement <'REQ-002'> by navprocessor;
	}
}
