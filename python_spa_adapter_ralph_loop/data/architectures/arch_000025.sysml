package arch_000025 {
	// Thermal Control Reference Architecture 25
	// Domain: thermal control

	import ScalarValues::*;

	// Interface Definitions
	interface def CommandIF;
	interface def ControlIF;
	interface def DataIF;
	interface def PowerIF;
	interface def ThermalIF;

	// Part Definitions
	part def ThermalControlSystem {
	}

	part def FlightPayload {
		port configIn : CommandIF;
		port cmdIn : ControlIF;
		port dataOut : PowerIF;
	}

	part def FlightInterface {
		port dataOut : DataIF;
		port sensorOut : ThermalIF;
		port configIn : ThermalIF;
	}

	part def DataInterface {
		port pwrOut : PowerIF;
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
		part flightpayload : FlightPayload;
		part flightinterface : FlightInterface;
		part datainterface : DataInterface;

		// Connections
		connection : link1 connect 
			flightpayload.dataOut to datainterface.pwrOut;
		connection : link2 connect 
			flightpayload.cmdIn to flightinterface.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by datainterface;
		satisfy requirement <'REQ-002'> by flightpayload;
	}
}
