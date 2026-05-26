# IR Schema v0

The MVP IR is JSON.

## Top Level

```json
{
  "schema": "sysml-ir-v0",
  "id": "UAVPowerExample001",
  "package": {
    "name": "UAVPowerExample001",
    "members": []
  }
}
```

## Supported Member Kinds

### part_def

```json
{
  "kind": "part_def",
  "name": "PowerSubsystem",
  "parts": [
    {"name": "battery", "type": "BatteryUnit"},
    {"name": "controller", "type": "PowerControllerUnit"}
  ]
}
```

### requirement_def

```json
{
  "kind": "requirement_def",
  "name": "VoltageRequirement",
  "doc": "The system shall maintain voltage under nominal operating conditions."
}
```

### verification_case_def

```json
{
  "kind": "verification_case_def",
  "name": "VoltageVerification",
  "subject": "VoltageRequirement"
}
```

## Renderer Target

A valid rendered shape may look like:

```sysml
package UAVPowerExample001 {
    part def PowerSubsystem {
        part battery : BatteryUnit;
        part controller : PowerControllerUnit;
    }

    part def BatteryUnit;
    part def PowerControllerUnit;

    requirement def VoltageRequirement {
        doc /* The system shall maintain voltage under nominal operating conditions. */
    }

    verification case def VoltageVerification {
        subject VoltageRequirement;
    }
}
```

If the exact SysML v2 syntax must be adjusted for the current pilot parser, update the renderer and fixtures.
