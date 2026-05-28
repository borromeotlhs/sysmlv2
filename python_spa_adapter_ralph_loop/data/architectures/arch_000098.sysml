package arch_000098 {

    // Solar Array Reference Architecture 98
    // Domain: solar array

    // Requirements
    requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    requirement REQ_004 {
        doc "The solar array system shall maintain operational status monitoring."
    }

    // Component Definitions
    part def PowerInterface {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut;
        port cmdIn;
        port ctrlIn;
    }

    part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port dataOut;
    }

    part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port cmdOut;
        port pwrIn;
    }

    // System Definition
    part def SolarArraySystem {
        part powerinterface : PowerInterface {
            satisfy REQ_003;
        }
        part flightprocessor : FlightProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect dataprocessor.cmdOut to powerinterface.cmdIn;
        connect flightprocessor.pwrIn to powerinterface.ctrlIn;
        connect dataprocessor.pwrIn to powerinterface.cmdIn;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}