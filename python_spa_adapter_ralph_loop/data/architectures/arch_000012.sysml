package arch_000012 {
	// Solar Array Reference Architecture 12
	// Domain: solar array

	import ScalarValues::*;

	// Interface Definitions
	interface def ControlIF;
	interface def DataIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def SolarArraySystem {
	}

	part def PowerPayload {
		port pwrOut : ControlIF;
		port sensorOut : DataIF;
	}

	part def FlightBus {
		port dataIn : ThermalIF;
	}

	part def PowerModule {
		port dataIn : ThermalIF;
		port cmdOut : StatusIF;
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
		part powerpayload : PowerPayload;
		part flightbus : FlightBus;
		part powermodule : PowerModule;

		// Connections
		connection : link1 connect 
			flightbus.dataIn to powermodule.cmdOut;
		connection : link2 connect 
			powermodule.dataIn to powerpayload.pwrOut;
		connection : link3 connect 
			powermodule.cmdOut to powerpayload.pwrOut;
		connection : link4 connect 
			powerpayload.pwrOut to flightbus.dataIn;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by powermodule;
		satisfy requirement <'REQ-001'> by powerpayload;
		satisfy requirement <'REQ-002'> by powerpayload;
		satisfy requirement <'REQ-002'> by flightbus;
		satisfy requirement <'REQ-003'> by flightbus;
		satisfy requirement <'REQ-003'> by powerpayload;
	}
}
