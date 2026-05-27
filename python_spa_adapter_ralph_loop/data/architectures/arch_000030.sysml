package arch_000030 {
	// Antenna Subsystem Reference Architecture 30
	// Domain: antenna subsystem

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def AntennaSubsystemSystem {
	}

	part def ThermalController {
		port pwrOut : PowerIF;
	}

	part def CommController {
		port sensorOut : DataIF;
	}

	part def DataSubsystem {
		port sensorOut : ThermalIF;
		port pwrOut : ControlIF;
		port telemetryOut : PowerIF;
	}

	part def ControlSubsystem {
		port cmdOut : PowerIF;
	}

	part def SensorController {
		port dataOut : PowerIF;
		port configIn : PowerIF;
	}

	part def CommUnit {
		port cmdOut : PowerIF;
		port telemetryOut : TelemetryIF;
		port ctrlIn : DiagnosticIF;
	}

	part def ProcessingAssembly {
		port ctrlIn : DiagnosticIF;
		port telemetryOut : DiagnosticIF;
		port pwrOut : ControlIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The antenna subsystem system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The antenna subsystem system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part antennasubsystemsystem : AntennaSubsystemSystem {
		part thermalcontroller : ThermalController;
		part commcontroller : CommController;
		part datasubsystem : DataSubsystem;
		part controlsubsystem : ControlSubsystem;
		part sensorcontroller : SensorController;
		part communit : CommUnit;
		part processingassembly : ProcessingAssembly;

		// Connections
		connection : link1 connect 
			sensorcontroller.configIn to commcontroller.sensorOut;
		connection : link2 connect 
			sensorcontroller.configIn to communit.ctrlIn;
		connection : link3 connect 
			processingassembly.telemetryOut to datasubsystem.telemetryOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by sensorcontroller;
		satisfy requirement <'REQ-001'> by thermalcontroller;
		satisfy requirement <'REQ-002'> by controlsubsystem;
		satisfy requirement <'REQ-002'> by processingassembly;
	}
}
