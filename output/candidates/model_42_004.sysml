package model_42_004 {
    part def BatteryController571 {
        part powersubsystem842 : PowerComponent411;
        part navigationsystem217 : SensorController323;
    }

    part def PowerComponent411;

    part def SensorController323;

    requirement def PerformanceRequirement51 {
        doc /* All performance parameters shall be monitored continuously. */
    }

    requirement def PerformanceRequirement19 {
        doc /* The performance shall meet operational requirements. */
    }

    requirement def CurrentRequirement32 {
        doc /* All current parameters shall be monitored continuously. */
    }

    verification case def PerformanceVerification51 {
        subject PerformanceRequirement51;
    }

    verification case def PerformanceVerification19 {
        subject PerformanceRequirement19;
    }

    verification case def CurrentVerification32 {
        subject CurrentRequirement32;
    }
}
