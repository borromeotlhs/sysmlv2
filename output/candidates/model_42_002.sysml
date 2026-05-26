package model_42_002 {
    part def PowerSubsystem715 {
        part flightsubsystem981 : NavigationSystem095;
        part communicationsystem368 : NavigationModule271;
    }

    part def NavigationSystem095;

    part def NavigationModule271;

    requirement def PerformanceRequirement69 {
        doc /* The system shall maintain performance within specified limits. */
    }

    requirement def PerformanceRequirement11 {
        doc /* All performance parameters shall be monitored continuously. */
    }

    requirement def TemperatureRequirement81 {
        doc /* All temperature parameters shall be monitored continuously. */
    }

    verification case def PerformanceVerification11 {
        subject PerformanceRequirement11;
    }

    verification case def TemperatureVerification81 {
        subject TemperatureRequirement81;
    }
}
