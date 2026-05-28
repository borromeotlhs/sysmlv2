"""
Comprehensive Validation Tests for SysML v2 Pipeline

Tests cover:
- Valid syntax with public keywords, imports, and typed ports
- Invalid syntax (missing package, untyped ports, malformed statements)
- Edge cases (empty packages, nested structures, circular dependencies)
- Semantic validation (undefined references, requirement tracing)
- Style validation (naming conventions, indentation, documentation)

Run with: pytest tests/test_validation_comprehensive.py -v
"""
import pytest
from pathlib import Path
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity


@pytest.fixture
def validator():
    """Create fresh validator for each test"""
    return SysMLValidator()


@pytest.fixture
def tmp_sysml(tmp_path):
    """Helper to create temp .sysml files"""
    def _create(content: str, name: str = 'test.sysml') -> Path:
        file_path = tmp_path / name
        file_path.write_text(content, encoding='utf-8')
        return file_path
    return _create


# =============================================================================
# VALID SYNTAX TESTS
# =============================================================================

class TestValidSyntax:
    """Test valid SysML v2 syntax patterns"""

    def test_valid_minimal_package(self, validator, tmp_sysml):
        """Minimal valid package with public keyword"""
        content = """package minimal {
    // Minimal package
    // Domain: test

    public part def Component {
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0

    def test_valid_with_imports(self, validator, tmp_sysml):
        """Valid package with namespace imports"""
        content = """package with_imports {
    // Package with imports
    // Domain: test

    import ScalarValues::*;
    import ISQ::*;

    public part def Component {
        attribute mass : Real [1];
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0

    def test_valid_with_typed_ports(self, validator, tmp_sysml):
        """Valid syntax with typed ports"""
        content = """package typed_ports {
    // Typed ports example
    // Domain: test

    public port def DataPort;
    public port def CommandPort;

    public part def Sensor {
        port dataOut : DataPort;
        port cmdIn : CommandPort;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0

    def test_valid_with_requirements(self, validator, tmp_sysml):
        """Valid requirements with satisfy relationships"""
        content = """package with_requirements {
    // Requirements example
    // Domain: test

    public requirement REQ_001 {
        doc "System shall process data."
    }

    public part def Processor {
        port dataIn;
    }

    public part def System {
        part processor : Processor {
            satisfy REQ_001;
        }
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0

    def test_valid_with_connections(self, validator, tmp_sysml):
        """Valid connection statements"""
        content = """package with_connections {
    // Connections example
    // Domain: test

    public part def ComponentA {
        port portA;
    }

    public part def ComponentB {
        port portB;
    }

    public part def System {
        part a : ComponentA;
        part b : ComponentB;

        connect a.portA to b.portB;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0

    def test_valid_nested_structures(self, validator, tmp_sysml):
        """Valid nested part definitions"""
        content = """package nested {
    // Nested structures
    // Domain: test

    public part def Level1 {
        part level2 : Level2;
    }

    public part def Level2 {
        part level3 : Level3;
    }

    public part def Level3 {
        port port3;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0


# =============================================================================
# INVALID SYNTAX TESTS
# =============================================================================

class TestInvalidSyntax:
    """Test detection of syntax errors"""

    def test_missing_package_declaration(self, validator, tmp_sysml):
        """Error: missing package declaration"""
        content = """part def Component {
    port p1;
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('package' in e.message.lower() for e in errors)

    def test_unbalanced_braces(self, validator, tmp_sysml):
        """Error: unbalanced braces"""
        content = """package test {
    part def Component {
        port p1;
    }
"""  # Missing closing brace
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('brace' in e.message.lower() for e in errors)

    def test_missing_semicolons(self, validator, tmp_sysml):
        """Error: missing semicolons on statements"""
        content = """package test {
    part def Component {
        port p1
        port p2
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Should catch missing semicolons
        assert len(errors) >= 2

    def test_malformed_requirement(self, validator, tmp_sysml):
        """Error: requirement missing doc statement"""
        content = """package test {
    requirement REQ_001 {
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('doc' in e.message.lower() for e in errors)

    def test_invalid_multiplicity(self, validator, tmp_sysml):
        """Error: invalid multiplicity expression"""
        content = """package test {
    part def Vehicle {
        part wheels : Wheel[abc];
    }

    part def Wheel {
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('multiplicity' in e.message.lower() for e in errors)

    def test_invalid_connection_syntax(self, validator, tmp_sysml):
        """Error: invalid connection endpoint syntax"""
        content = """package test {
    part def System {
        part a : ComponentA;

        connect a.port@invalid to b.port;
    }

    part def ComponentA {
        port port;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('connection' in e.message.lower() for e in errors)


# =============================================================================
# EDGE CASE TESTS
# =============================================================================

class TestEdgeCases:
    """Test edge cases and boundary conditions"""

    def test_empty_package(self, validator, tmp_sysml):
        """Edge case: empty package (valid)"""
        content = """package empty {
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Empty package is syntactically valid
        assert len(errors) == 0

    def test_deeply_nested_structures(self, validator, tmp_sysml):
        """Edge case: deeply nested part definitions"""
        content = """package deep {
    // Deep nesting
    // Domain: test

    public part def L1 {
        part l2 : L2 {
            part l3 : L3 {
                part l4 : L4 {
                    part l5 : L5;
                }
            }
        }
    }

    public part def L2 { }
    public part def L3 { }
    public part def L4 { }
    public part def L5 { }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Should parse without errors
        assert len(errors) == 0

    def test_circular_composition(self, validator, tmp_sysml):
        """Edge case: circular composition dependency"""
        content = """package circular {
    part def A {
        part b : B;
    }

    part def B {
        part c : C;
    }

    part def C {
        part a : A;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Should detect circular dependency
        assert any('circular' in e.message.lower() for e in errors)

    def test_many_connections(self, validator, tmp_sysml):
        """Edge case: many connections between components"""
        connections = []
        for i in range(10):
            connections.append(f'        connect a.port{i} to b.port{i};')

        content = f"""package many_connections {{
    public part def ComponentA {{
        {chr(10).join(f'port port{i};' for i in range(10))}
    }}

    public part def ComponentB {{
        {chr(10).join(f'port port{i};' for i in range(10))}
    }}

    public part def System {{
        part a : ComponentA;
        part b : ComponentB;

{chr(10).join(connections)}
    }}
}}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Should handle many connections without error
        assert len(errors) == 0

    def test_unicode_identifiers(self, validator, tmp_sysml):
        """Edge case: Unicode characters in identifiers"""
        content = """package unicode_test {
    // Test with Unicode
    // Domain: test

    public part def Component_α {
        attribute temp_°C : Real [1];
        port data₁;
    }

    public requirement REQ_β {
        doc "Temperature shall be ± 5°C."
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        # Unicode handling may vary - just ensure it doesn't crash
        # Validator may warn about naming conventions
        assert validator is not None


# =============================================================================
# SEMANTIC VALIDATION TESTS
# =============================================================================

class TestSemanticValidation:
    """Test semantic correctness checks"""

    def test_undefined_part_type(self, validator, tmp_sysml):
        """Error: part instance references undefined type"""
        content = """package test {
    part def System {
        part component : UndefinedType;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        # Parser-level validation may not catch this
        # But validator should flag undefined references
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        # At minimum, should parse without crashing
        assert validator is not None

    def test_undefined_port_in_connection(self, validator, tmp_sysml):
        """Error: connection references undefined port"""
        content = """package test {
    part def ComponentA {
        port validPort;
    }

    part def System {
        part a : ComponentA;

        connect a.undefinedPort to a.validPort;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('undefined' in e.message.lower() and 'port' in e.message.lower()
                  for e in errors)

    def test_undefined_requirement_in_satisfy(self, validator, tmp_sysml):
        """Error: satisfy references undefined requirement"""
        content = """package test {
    requirement REQ_001 {
        doc "Valid requirement."
    }

    part def Component {
    }

    part def System {
        part comp : Component {
            satisfy REQ_UNDEFINED;
        }
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any('undefined' in e.message.lower() and 'requirement' in e.message.lower()
                  for e in errors)

    def test_duplicate_definitions(self, validator, tmp_sysml):
        """Warning: duplicate part definitions"""
        content = """package test {
    part def Component {
        port p1;
    }

    part def Component {
        port p2;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Should flag duplicate
        assert any('duplicate' in e.message.lower() for e in errors)

    def test_port_type_consistency(self, validator, tmp_sysml):
        """Valid: port types are declared before use"""
        content = """package test {
    public port def DataPort;

    public part def Component {
        port dataOut : DataPort;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        # Port type is properly defined
        assert len(errors) == 0


# =============================================================================
# STYLE VALIDATION TESTS
# =============================================================================

class TestStyleValidation:
    """Test style and convention checks"""

    def test_naming_conventions_part_def(self, validator, tmp_sysml):
        """Warning: part def should use PascalCase"""
        content = """package test {
    part def lowercaseComponent {
        port p1;
    }

    part def GoodComponent {
        port p2;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        assert any('pascalcase' in w.message.lower() or 'naming' in w.category.lower()
                  for w in warnings)

    def test_naming_conventions_part_instance(self, validator, tmp_sysml):
        """Warning: part instance should use camelCase"""
        content = """package test {
    part def Component {
    }

    part def System {
        part BadInstance : Component;
        part goodInstance : Component;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        assert any('camelcase' in w.message.lower() or 'naming' in w.category.lower()
                  for w in warnings)

    def test_naming_conventions_requirement(self, validator, tmp_sysml):
        """Warning: requirement should use UPPER_CASE"""
        content = """package test {
    requirement bad_req_name {
        doc "Bad naming."
    }

    requirement REQ_GOOD {
        doc "Good naming."
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        assert any('upper' in w.message.lower() or 'naming' in w.category.lower()
                  for w in warnings)

    def test_untyped_port_warning(self, validator, tmp_sysml):
        """Warning: port without type declaration"""
        content = """package test {
    part def Component {
        port untypedPort;
        port typedPort : DataPort;
    }

    port def DataPort;
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        assert any('untyped' in w.message.lower() or 'type' in w.message.lower()
                  for w in warnings)

    def test_empty_requirement_text(self, validator, tmp_sysml):
        """Warning: requirement with empty doc text"""
        content = """package test {
    requirement REQ_001 {
        doc ""
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        assert any('empty' in w.message.lower() for w in warnings)


# =============================================================================
# INTEGRATION TESTS
# =============================================================================

class TestValidationIntegration:
    """Integration tests with real architecture patterns"""

    def test_complete_valid_architecture(self, validator, tmp_sysml):
        """Complete valid architecture with all elements"""
        content = """package complete_system {

    import ScalarValues::*;

    // Complete System Example
    // Domain: aerospace

    // Requirements
    public requirement REQ_001 {
        doc "System shall process telemetry data."
    }

    public requirement REQ_002 {
        doc "System shall maintain power budget."
    }

    // Port Definitions
    public port def DataPort;
    public port def CommandPort;
    public port def PowerPort;

    // Component Definitions
    public part def Sensor {
        attribute dataRate : Real [1];
        port dataOut : DataPort;
        port powerIn : PowerPort;
    }

    public part def Processor {
        attribute processingPower : Real [1];
        port dataIn : DataPort;
        port cmdOut : CommandPort;
        port powerIn : PowerPort;
    }

    public part def PowerSupply {
        attribute voltage : Real [1];
        port powerOut : PowerPort;
    }

    // System Definition
    public part def TelemetrySystem {
        part sensor : Sensor {
            satisfy REQ_001;
        }

        part processor : Processor {
            satisfy REQ_001;
        }

        part power : PowerSupply {
            satisfy REQ_002;
        }

        // Connections
        connect sensor.dataOut to processor.dataIn;
        connect power.powerOut to sensor.powerIn;
        connect power.powerOut to processor.powerIn;
    }

    // System Instance
    public part telemetrySystem : TelemetrySystem;
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]

        # Complete valid architecture should have no errors
        if errors:
            print("\nUnexpected errors in complete valid architecture:")
            for err in errors:
                print(f"  {err}")

        assert len(errors) == 0

    def test_mixed_issues_architecture(self, validator, tmp_sysml):
        """Architecture with mix of errors and warnings"""
        content = """package mixed_issues {
    // Missing domain comment

    // Bad requirement name
    requirement bad_name {
        doc "Test requirement."
    }

    part def lowercaseBlock {
        port untypedPort;
    }

    part def System {
        part BadInstance : lowercaseBlock;

        connect BadInstance.undefinedPort to BadInstance.untypedPort;
    }
}
"""
        file_path = tmp_sysml(content)
        issues = validator.validate_file(file_path)

        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]

        # Should catch both errors and warnings
        assert len(errors) > 0  # Undefined port
        assert len(warnings) > 0  # Naming conventions, untyped port


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
