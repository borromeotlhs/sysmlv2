package test_view_filter {

    // Test architecture for view filtering
    // Domain: test

    // Requirements
    public requirement REQ_001 {
        doc "The system shall provide filtered views."
    }

    // Public components (visible in filtered views)
    public part def ControlUnit {
        attribute processingPower : Real [1];
        port cmdIn;
        port cmdOut;
    }

    public part def SensorModule {
        attribute resolution : Real [1];
        port dataOut;
    }

    // Private/internal component (hidden in filtered views)
    public part def InternalProcessor {
        attribute cores : Real [1];
        port procIn;
        port procOut;
    }

    public part def PowerSupply {
        attribute voltage : Real [1];
        port pwrOut;
    }

    // System Definition
    public part def TestSystem {
        part control : ControlUnit {
            satisfy REQ_001;
        }
        part sensor : SensorModule;
        part processor : InternalProcessor;
        part power : PowerSupply;

        // Connections
        connect control.cmdOut to sensor.dataOut;
        connect control.cmdIn to processor.procOut;
        connect power.pwrOut to processor.procIn;
    }

    // System Instance
    part testSystem : TestSystem;
}
