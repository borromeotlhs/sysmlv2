package arch_000036 {
	// Thermal Control Reference Architecture 36
	// Domain: thermal control

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def DataIF;
	interface def DiagnosticIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def TelemetryIF;
	interface def ThermalIF;

	// Part Definitions
	part def ThermalControlSystem {
	}

	part def DistributionComputer {
		port telemetryOut : TelemetryIF;
		port cmdIn : PowerIF;
		port cmdOut : ThermalIF;
	}

	part def FlightInterface {
		port pwrOut : ControlIF;
		port statusOut : DiagnosticIF;
		port cmdIn : DiagnosticIF;
	}

	part def MonitorSubsystem {
		port telemetryOut : TelemetryIF;
	}

	part def ThermalSensor {
		port pwrOut : TelemetryIF;
		port cmdOut : DiagnosticIF;
	}

	part def DistributionBus {
		port sensorOut : ControlIF;
	}

	part def MonitorProcessor {
		port pwrOut : SignalIF;
		port dataOut : DataIF;
	}

	part def MissionProcessor {
		port dataIn : TelemetryIF;
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

	requirement <'REQ-004'> {
		doc /* The thermal control system shall maintain operational status monitoring. */
	}

	// System Assembly
	part thermalcontrolsystem : ThermalControlSystem {
		part distributioncomputer : DistributionComputer;
		part flightinterface : FlightInterface;
		part monitorsubsystem : MonitorSubsystem;
		part thermalsensor : ThermalSensor;
		part distributionbus : DistributionBus;
		part monitorprocessor : MonitorProcessor;
		part missionprocessor : MissionProcessor;

		// Connections
		connection : link1 connect 
			thermalsensor.cmdOut to distributioncomputer.cmdIn;
		connection : link2 connect 
			missionprocessor.dataIn to flightinterface.statusOut;
		connection : link3 connect 
			flightinterface.pwrOut to distributionbus.sensorOut;
		connection : link4 connect 
			monitorprocessor.dataOut to thermalsensor.pwrOut;
		connection : link5 connect 
			distributioncomputer.cmdIn to thermalsensor.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributioncomputer;
		satisfy requirement <'REQ-001'> by monitorprocessor;
		satisfy requirement <'REQ-002'> by monitorprocessor;
		satisfy requirement <'REQ-002'> by monitorsubsystem;
		satisfy requirement <'REQ-003'> by distributionbus;
		satisfy requirement <'REQ-004'> by monitorsubsystem;
		satisfy requirement <'REQ-004'> by flightinterface;
	}
}
