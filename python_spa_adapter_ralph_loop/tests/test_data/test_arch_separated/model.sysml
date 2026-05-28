package test_arch_sep {

    // Test Architecture Separated - Model
    // Domain: test

    // Requirements
    requirement REQ_SEP_001 {
        doc "The separated system shall support model/view separation."
    }

    // Component Definitions
    part def Controller {
        port cmdIn;
        port cmdOut;
    }

    part def Sensor {
        port dataOut;
    }

    part def Actuator {
        port ctrlIn;
    }

    // System Definition
    part def SeparatedSystem {
        part controller : Controller {
            satisfy REQ_SEP_001;
        }
        part sensor : Sensor;
        part actuator : Actuator;

        // Connections
        connect sensor.dataOut to controller.cmdIn;
        connect controller.cmdOut to actuator.ctrlIn;
    }

    // System Instance
    part separatedSystem : SeparatedSystem;
}
