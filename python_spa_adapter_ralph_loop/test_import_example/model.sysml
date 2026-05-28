package test_arch_001 {

    // Simple Test Architecture
    // Domain: test system

    // Requirements
    requirement REQ_001 {
        doc "The system shall have proper component interfaces."
    }

    requirement REQ_002 {
        doc "The system shall connect components properly."
    }

    // Component Definitions
    part def Controller {
        attribute cpuSpeed : Real [1];
        port cmdOut;
    }

    part def Sensor {
        attribute sampleRate : Real [1];
        port dataOut;
    }

    part def Actuator {
        attribute torque : Real [1];
        port cmdIn;
    }

    // System Definition
    part def TestSystem {
        part controller : Controller {
            satisfy REQ_001;
        }
        part sensor : Sensor {
            satisfy REQ_001;
        }
        part actuator : Actuator {
            satisfy REQ_002;
        }

        // Connections
        connect controller.cmdOut to actuator.cmdIn;
        connect sensor.dataOut to controller.cmdOut;
    }

    // System Instance
    part testsystem : TestSystem;

}
