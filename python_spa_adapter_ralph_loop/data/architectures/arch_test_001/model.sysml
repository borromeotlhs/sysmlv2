package arch_test_001 {

    // Test Architecture 1 - Model-View Separation Demo
    // Domain: test system

    // Requirements
    requirement REQ_001 {
        doc "The system shall demonstrate model-view separation."
    }

    requirement REQ_002 {
        doc "The system shall support multiple diagram views."
    }

    // Component Definitions
    part def Controller {
        attribute processingPower : Real [1];
        port cmdOut;
    }

    part def Sensor {
        attribute dataRate : Real [1];
        port dataOut;
    }

    part def Actuator {
        attribute voltage : Real [1];
        port cmdIn;
    }

    // System Definition
    part def TestSystem {
        part controller : Controller {
            satisfy REQ_001;
        }
        part sensor : Sensor {
            satisfy REQ_002;
        }
        part actuator : Actuator;

        // Connections
        connect controller.cmdOut to actuator.cmdIn;
        connect sensor.dataOut to controller.cmdOut;
    }

    // System Instance
    part testsystem : TestSystem;

}
