package arch_000161 {

    // Fuel Cell Reference Architecture 161
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The fuel cell system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ControlInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port statusOut;
    }

    public part def CommandBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
    }

    public part def CommSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
        port dataOut;
    }

    public part def ProcessingModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port sensorOut;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port telemetryOut;
    }

    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port dataIn;
    }

    // System Definition
    public part def FuelCellSystem {
        part controlinterface : ControlInterface {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part commandbus : CommandBus {
        }
        part commsensor : CommSensor {
        }
        part processingmodule : ProcessingModule {
        }
        part flightassembly : FlightAssembly {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part sensoractuator : SensorActuator {
            satisfy REQ_001;
        }
        part dataassembly : DataAssembly {
        }

        // Connections
        connect flightassembly.sensorOut to dataassembly.dataIn;
        connect commandbus.cmdOut to dataassembly.dataIn;
        connect sensoractuator.configIn to controlinterface.statusOut;
    }

    // System Instance
    part fuelcellsystem : FuelCellSystem;

}