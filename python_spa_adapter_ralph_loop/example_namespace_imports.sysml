// Example demonstrating three SysML v2 namespace import patterns
// Domain: aerospace

package Systems {
    // Public elements (visible with ::*)
    public part def PowerSystem {
        part battery : Battery;
    }

    public part def CoolingSystem {
        part radiator : Radiator;
    }

    // Internal elements (not visible with ::*, only with :: ** or ::*::** )
    part def Battery {
        part cell : Cell[4];
        port positive;
        port negative;
    }

    part def Radiator {
        port inlet;
        port outlet;
    }

    part def Cell {
        port positive;
        port negative;
    }
}

package DirectImportExample {
    // Import pattern 1: Direct members only (::*)
    // Makes visible: PowerSystem, CoolingSystem
    // Does NOT make visible: Battery, Radiator, Cell
    import Systems::*;

    public part def SimpleVehicle {
        // Can reference PowerSystem and CoolingSystem directly
        part power : PowerSystem;
        part cooling : CoolingSystem;
    }
}

package RecursiveImportExample {
    // Import pattern 2: Recursive nested only (::**)
    // Makes visible: Battery, Radiator, Cell
    // Does NOT make visible: PowerSystem, CoolingSystem
    import Systems::**;

    public part def CustomPowerUnit {
        // Can reference nested types but not top-level Systems types
        part customBattery : Battery;
        part coolant : Radiator;
    }
}

package HybridImportExample {
    // Import pattern 3: Direct + recursive (::*::**)
    // Makes visible: PowerSystem, CoolingSystem, Battery, Radiator, Cell
    import Systems::*::**;

    public part def AdvancedVehicle {
        // Can reference both top-level and nested types
        part mainPower : PowerSystem;
        part backupBattery : Battery;
        part primaryCooling : CoolingSystem;
        part secondaryCooling : Radiator;
    }
}

package NoImportExample {
    // No imports - only locally defined elements are visible
    public part def StandaloneSystem {
        part def LocalComponent {
            port input;
            port output;
        }

        part component : LocalComponent;
    }
}
