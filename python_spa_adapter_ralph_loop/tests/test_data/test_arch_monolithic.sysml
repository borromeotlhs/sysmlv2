package test_arch_mono {

    // Test Architecture Monolithic
    // Domain: test

    // Requirements
    requirement REQ_TEST_001 {
        doc "The system shall provide basic functionality."
    }

    // Component Definitions
    part def ComponentA {
        port portIn;
        port portOut;
    }

    part def ComponentB {
        port dataIn;
        port dataOut;
    }

    // System Definition
    part def TestSystem {
        part compA : ComponentA {
            satisfy REQ_TEST_001;
        }
        part compB : ComponentB;

        // Connections
        connect compA.portOut to compB.dataIn;
    }

    // System Instance
    part testSystem : TestSystem;
}
