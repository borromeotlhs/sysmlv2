package model_42_003 {
    part def PowerSystem678 {
        part powersubsystem888 : PowerUnit285;
        part communicationcontroller855 : NavigationSubsystem380;
    }

    part def PowerUnit285;

    part def NavigationSubsystem380;

    part def FlightController274;

    requirement def WeightRequirement83 {
        doc /* The system shall maintain weight within specified limits. */
    }

    requirement def SafetyRequirement82 {
        doc /* The system shall maintain safety within specified limits. */
    }

    requirement def SafetyRequirement94 {
        doc /* The system shall maintain safety within specified limits. */
    }

    verification case def WeightVerification83 {
        subject WeightRequirement83;
    }

    verification case def SafetyVerification82 {
        subject SafetyRequirement82;
    }
}
