package arch_000032 {
	// Ground Station Reference Architecture 32
	// Domain: ground station

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def SignalIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def GroundStationSystem {
	}

	part def ProcessingController {
		port sensorOut : DataIF;
		port telemetryOut : StatusIF;
		port sensorOut : ControlIF;
	}

	part def PowerSensor {
		port pwrOut : SignalIF;
	}

	part def CommInterface {
		port dataOut : ControlIF;
	}

	part def DistributionAssembly {
		port dataOut : ThermalIF;
		port dataIn : PowerIF;
	}

	part def CommandInterface {
		port pwrIn : DataIF;
	}

	part def ProcessingBus {
		port sensorOut : ConfigIF;
		port cmdIn : ControlIF;
		port configIn : PowerIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The ground station system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The ground station system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part groundstationsystem : GroundStationSystem {
		part processingcontroller : ProcessingController;
		part powersensor : PowerSensor;
		part comminterface : CommInterface;
		part distributionassembly : DistributionAssembly;
		part commandinterface : CommandInterface;
		part processingbus : ProcessingBus;

		// Connections
		connection : link1 connect 
			processingcontroller.sensorOut to processingbus.cmdIn;
		connection : link2 connect 
			commandinterface.pwrIn to processingcontroller.sensorOut;
		connection : link3 connect 
			distributionassembly.dataOut to processingbus.configIn;
		connection : link4 connect 
			commandinterface.pwrIn to processingbus.cmdIn;
		connection : link5 connect 
			commandinterface.pwrIn to powersensor.pwrOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by distributionassembly;
		satisfy requirement <'REQ-001'> by powersensor;
		satisfy requirement <'REQ-002'> by processingbus;
		satisfy requirement <'REQ-002'> by commandinterface;
	}
}
