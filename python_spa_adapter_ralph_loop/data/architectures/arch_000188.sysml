package arch_000188 {

    // Thermal Control Reference Architecture 188
    // Domain: thermal control

    // Requirements
    requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The thermal control system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port pwrOut;
    }

    part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut;
        port configIn;
        port cmdIn;
    }

    part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port ctrlIn;
        port ctrlIn;
    }

    part def ProcessingInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port dataOut;
    }

    // System Definition
    part def ThermalControlSystem {
        part distributionunit : DistributionUnit {
            satisfy REQ_002;
        }
        part thermalassembly : ThermalAssembly {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part missionprocessor : MissionProcessor {
        }
        part commandactuator : CommandActuator {
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_002;
        }
        part flightprocessor : FlightProcessor {
        }
        part processinginterface : ProcessingInterface {
        }

        // Connections
        connect thermalassembly.statusOut to commandactuator.pwrOut;
        connect monitorsubsystem.configIn to flightprocessor.cmdOut;
    }

    // System Instance
    part thermalcontrolsystem : ThermalControlSystem;

}