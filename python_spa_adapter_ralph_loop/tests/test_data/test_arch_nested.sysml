package test_arch_nested {

    // Test Architecture with Nested Components
    // Domain: test

    // Component Definitions
    part def SubsystemA {
        port interfaceA;

        part def InternalComponent1 {
            port portIn;
            port portOut;
        }

        part internal1 : InternalComponent1;
    }

    part def SubsystemB {
        port interfaceB;

        part def InternalComponent2 {
            port portIn;
            port portOut;
        }

        part internal2 : InternalComponent2;
    }

    // System Definition
    part def NestedSystem {
        part subsystemA : SubsystemA;
        part subsystemB : SubsystemB;

        // Connections
        connect subsystemA.interfaceA to subsystemB.interfaceB;
    }

    // System Instance
    part nestedSystem : NestedSystem;
}
