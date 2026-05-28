package arch_000155 {

    // Power Distribution System Reference Architecture 155
    // Domain: power distribution system

    // Requirements
    requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The power distribution system system shall provide fault detection and recovery."
    }

    requirement REQ_004 {
        doc "The power distribution system system shall maintain operational status monitoring."
    }

    // Component Definitions
    part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port dataIn;
    }

    part def FlightActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port pwrIn;
        port cmdIn;
    }

    part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port ctrlIn;
        port cmdIn;
    }

    part def ThermalSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port telemetryOut;
    }

    part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port statusOut;
    }

    part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port pwrOut;
        port ctrlIn;
    }

    // System Definition
    part def PowerDistributionSystemSystem {
        part monitorinterface : MonitorInterface {
        }
        part flightactuator : FlightActuator {
            satisfy REQ_001;
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_002;
        }
        part commandcomputer : CommandComputer {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part thermalsensor : ThermalSensor {
            satisfy REQ_004;
        }
        part thermalinterface : ThermalInterface {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part commandinterface : CommandInterface {
        }

        // Connections
        connect commandcomputer.cmdIn to flightactuator.ctrlIn;
        connect flightactuator.ctrlIn to commandinterface.ctrlIn;
        connect processingassembly.pwrOut to thermalsensor.pwrOut;
        connect thermalsensor.pwrOut to commandinterface.pwrOut;
    }

    // System Instance
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}