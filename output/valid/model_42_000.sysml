package model_42_000 {
    part def BatterySystem026;

    requirement def CurrentRequirement95 {
        doc /* The system shall maintain current within specified limits. */
    }

    verification case def CurrentVerification95 {
        subject CurrentRequirement95;
    }
}
