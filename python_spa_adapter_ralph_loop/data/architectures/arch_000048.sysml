package arch_000048 {
	// Propulsion Module Reference Architecture 48
	// Domain: propulsion module

	import ScalarValues::*;

	// Interface Definitions
	interface def ConfigIF;
	interface def ControlIF;
	interface def DataIF;
	interface def StatusIF;
	interface def ThermalIF;

	// Part Definitions
	part def PropulsionModuleSystem {
	}

	part def CommandSensor {
		port sensorOut : StatusIF;
	}

	part def NavModule {
		port sensorOut : ConfigIF;
		port dataIn : StatusIF;
	}

	part def DataUnit {
		port pwrIn : ThermalIF;
	}

	part def ProcessingProcessor {
		port telemetryOut : DataIF;
		port ctrlIn : ControlIF;
	}

	part def DistributionPayload {
		port sensorOut : ThermalIF;
	}

	// Requirements
	requirement <'REQ-001'> {
		doc /* The propulsion module system shall exchange data through typed interfaces. */
	}

	requirement <'REQ-002'> {
		doc /* The propulsion module system shall trace subsystem design to requirements. */
	}

	// System Assembly
	part propulsionmodulesystem : PropulsionModuleSystem {
		part commandsensor : CommandSensor;
		part navmodule : NavModule;
		part dataunit : DataUnit;
		part processingprocessor : ProcessingProcessor;
		part distributionpayload : DistributionPayload;

		// Connections
		connection : link1 connect 
			navmodule.dataIn to dataunit.pwrIn;
		connection : link2 connect 
			commandsensor.sensorOut to distributionpayload.sensorOut;

		// Requirement Satisfaction
		satisfy requirement <'REQ-001'> by processingprocessor;
		satisfy requirement <'REQ-002'> by dataunit;
	}
}
