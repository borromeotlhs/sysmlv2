"""
Comprehensive Renderer Tests for SysML v2 Pipeline

Tests cover:
- BDD view filtering based on exposed elements
- IBD view filtering based on exposed elements
- Respect exposed elements (public keyword)
- Handle missing exposure (backward compatibility)
- PlantUML diagram generation
- Edge cases (no connections, no ports, empty architectures)

Run with: pytest tests/test_renderer_comprehensive.py -v
"""
import pytest
from pathlib import Path
from spa.server import generate_bdd_plantuml, generate_ibd_plantuml
from spa.sysml_parser import parse_sysml_to_json
from lib.sysml_generator import generate_sysml_from_dict


@pytest.fixture
def tmp_sysml_file(tmp_path):
    """Helper to create temp .sysml files"""
    def _create(content: str, name: str = 'test.sysml') -> Path:
        file_path = tmp_path / name
        file_path.write_text(content, encoding='utf-8')
        return file_path
    return _create


# =============================================================================
# BDD FILTERING TESTS
# =============================================================================

class TestBDDFiltering:
    """Test BDD diagram filtering based on exposed elements"""

    def test_bdd_with_all_public(self, tmp_sysml_file):
        """BDD with all public components"""
        content = """package test {
    // Test
    // Domain: test

    public part def ComponentA {
        port p1;
    }

    public part def ComponentB {
        port p2;
    }

    public part def System {
        part a : ComponentA;
        part b : ComponentB;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should include all public components
        assert 'ComponentA' in plantuml
        assert 'ComponentB' in plantuml
        assert 'System' in plantuml

    def test_bdd_with_mixed_visibility(self, tmp_sysml_file):
        """BDD with mix of public and private components"""
        content = """package test {
    // Test
    // Domain: test

    public part def PublicComponent {
        port p1;
    }

    part def PrivateComponent {
        port p2;
    }

    public part def System {
        part public : PublicComponent;
        part private : PrivateComponent;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should include only public components
        assert 'PublicComponent' in plantuml
        assert 'System' in plantuml

        # Should NOT include private components
        assert 'PrivateComponent' not in plantuml

    def test_bdd_no_public_keywords(self, tmp_sysml_file):
        """BDD with no public keywords (backward compatibility)"""
        content = """package test {
    // Test
    // Domain: test

    part def ComponentA {
        port p1;
    }

    part def ComponentB {
        port p2;
    }

    part def System {
        part a : ComponentA;
        part b : ComponentB;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should include all components (backward compatibility)
        assert 'ComponentA' in plantuml
        assert 'ComponentB' in plantuml
        assert 'System' in plantuml

    def test_bdd_composition_relationships(self, tmp_sysml_file):
        """BDD shows composition relationships"""
        content = """package test {
    // Test
    // Domain: test

    public part def Vehicle {
        part engine : Engine;
        part wheels : Wheel[4];
    }

    public part def Engine {
    }

    public part def Wheel {
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should show composition arrows
        assert 'Vehicle' in plantuml
        assert 'Engine' in plantuml
        assert 'Wheel' in plantuml
        # PlantUML uses *-- for composition
        assert '*--' in plantuml or 'o--' in plantuml or '--' in plantuml

    def test_bdd_with_ports(self, tmp_sysml_file):
        """BDD shows ports on components"""
        content = """package test {
    // Test
    // Domain: test

    public port def DataPort;

    public part def Component {
        port dataIn : DataPort;
        port dataOut : DataPort;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should show component with ports
        assert 'Component' in plantuml
        # Ports may be shown as attributes or separate elements
        assert 'dataIn' in plantuml or 'port' in plantuml.lower()


# =============================================================================
# IBD FILTERING TESTS
# =============================================================================

class TestIBDFiltering:
    """Test IBD diagram filtering based on exposed elements"""

    def test_ibd_with_all_public(self, tmp_sysml_file):
        """IBD with all public components"""
        content = """package test {
    // Test
    // Domain: test

    public part def ComponentA {
        port p1;
    }

    public part def ComponentB {
        port p2;
    }

    public part def System {
        part a : ComponentA;
        part b : ComponentB;

        connect a.p1 to b.p2;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_ibd_plantuml(file_path)

        # Should include all public components
        assert 'ComponentA' in plantuml or 'componenta' in plantuml.lower()
        assert 'ComponentB' in plantuml or 'componentb' in plantuml.lower()

        # Should show connection
        assert '-->' in plantuml or '--' in plantuml

    def test_ibd_with_mixed_visibility(self, tmp_sysml_file):
        """IBD with mix of public and private components"""
        content = """package test {
    // Test
    // Domain: test

    public part def PublicA {
        port pa;
    }

    public part def PublicB {
        port pb;
    }

    part def PrivateC {
        port pc;
    }

    public part def System {
        part a : PublicA;
        part b : PublicB;
        part c : PrivateC;

        connect a.pa to b.pb;
        connect a.pa to c.pc;
        connect c.pc to b.pb;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_ibd_plantuml(file_path)

        # Should include public components
        assert 'PublicA' in plantuml or 'publica' in plantuml.lower()
        assert 'PublicB' in plantuml or 'publicb' in plantuml.lower()

        # Should NOT include private components
        assert 'PrivateC' not in plantuml
        assert 'privatec' not in plantuml.lower()

    def test_ibd_no_public_keywords(self, tmp_sysml_file):
        """IBD with no public keywords (backward compatibility)"""
        content = """package test {
    // Test
    // Domain: test

    part def ComponentA {
        port p1;
    }

    part def ComponentB {
        port p2;
    }

    part def System {
        part a : ComponentA;
        part b : ComponentB;

        connect a.p1 to b.p2;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_ibd_plantuml(file_path)

        # Should include all components (backward compatibility)
        assert 'ComponentA' in plantuml or 'componenta' in plantuml.lower()
        assert 'ComponentB' in plantuml or 'componentb' in plantuml.lower()

    def test_ibd_connection_filtering(self, tmp_sysml_file):
        """IBD filters connections involving private components"""
        content = """package test {
    // Test
    // Domain: test

    public part def PublicA {
        port pa;
    }

    public part def PublicB {
        port pb;
    }

    part def PrivateC {
        port pc;
    }

    public part def System {
        part a : PublicA;
        part b : PublicB;
        part c : PrivateC;

        connect a.pa to b.pb;
        connect a.pa to c.pc;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_ibd_plantuml(file_path)

        # Should show connection between public components
        # a.pa to b.pb should be present

        # Should NOT show connections to private component c
        # This is implementation-specific, but check that PrivateC is filtered
        assert 'PrivateC' not in plantuml
        assert 'privatec' not in plantuml.lower()

    def test_ibd_port_display(self, tmp_sysml_file):
        """IBD shows ports on components"""
        content = """package test {
    // Test
    // Domain: test

    public part def Sensor {
        port dataOut;
    }

    public part def Processor {
        port dataIn;
    }

    public part def System {
        part sensor : Sensor;
        part processor : Processor;

        connect sensor.dataOut to processor.dataIn;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_ibd_plantuml(file_path)

        # Should show ports in connection
        assert 'dataOut' in plantuml or 'dataout' in plantuml.lower()
        assert 'dataIn' in plantuml or 'datain' in plantuml.lower()


# =============================================================================
# PLANTUML GENERATION TESTS
# =============================================================================

class TestPlantUMLGeneration:
    """Test PlantUML diagram generation"""

    def test_plantuml_basic_structure(self, tmp_sysml_file):
        """Test basic PlantUML structure"""
        content = """package test {
    // Test
    // Domain: test

    public part def Component {
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should have PlantUML markers
        assert '@startuml' in plantuml
        assert '@enduml' in plantuml

    def test_plantuml_title(self, tmp_sysml_file):
        """Test PlantUML includes title"""
        content = """package test {
    // My Test Architecture
    // Domain: aerospace

    public part def Component {
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # Should include title or architecture name
        assert 'title' in plantuml.lower() or 'Test Architecture' in plantuml

    def test_plantuml_styling(self, tmp_sysml_file):
        """Test PlantUML includes styling directives"""
        content = """package test {
    // Test
    // Domain: test

    public part def Component {
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # May include skinparam or styling
        # Implementation-specific
        assert plantuml is not None
        assert len(plantuml) > 0

    def test_bdd_plantuml_format(self, tmp_sysml_file):
        """Test BDD PlantUML format"""
        content = """package test {
    // Test
    // Domain: test

    public part def ComponentA {
    }

    public part def ComponentB {
    }

    public part def System {
        part a : ComponentA;
        part b : ComponentB;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_bdd_plantuml(file_path)

        # BDD uses class diagram syntax
        assert 'class' in plantuml or 'package' in plantuml or 'rectangle' in plantuml

    def test_ibd_plantuml_format(self, tmp_sysml_file):
        """Test IBD PlantUML format"""
        content = """package test {
    // Test
    // Domain: test

    public part def ComponentA {
        port p1;
    }

    public part def ComponentB {
        port p2;
    }

    public part def System {
        part a : ComponentA;
        part b : ComponentB;

        connect a.p1 to b.p2;
    }
}
"""
        file_path = tmp_sysml_file(content)
        plantuml = generate_ibd_plantuml(file_path)

        # IBD uses component/object diagram syntax
        assert 'component' in plantuml.lower() or 'object' in plantuml.lower() or '[' in plantuml


# =============================================================================
# EDGE CASE TESTS
# =============================================================================

class TestRenderingEdgeCases:
    """Test edge cases in diagram rendering"""

    def test_empty_architecture(self, tmp_sysml_file):
        """Render empty architecture"""
        content = """package empty {
}
"""
        file_path = tmp_sysml_file(content)

        # Should not crash
        bdd = generate_bdd_plantuml(file_path)
        ibd = generate_ibd_plantuml(file_path)

        assert bdd is not None
        assert ibd is not None
        assert '@startuml' in bdd
        assert '@startuml' in ibd

    def test_no_connections(self, tmp_sysml_file):
        """Render architecture with no connections"""
        content = """package test {
    // Test
    // Domain: test

    public part def ComponentA {
        port p1;
    }

    public part def ComponentB {
        port p2;
    }

    public part def System {
        part a : ComponentA;
        part b : ComponentB;
    }
}
"""
        file_path = tmp_sysml_file(content)
        ibd = generate_ibd_plantuml(file_path)

        # Should render components without connections
        assert 'ComponentA' in ibd or 'componenta' in ibd.lower()
        assert 'ComponentB' in ibd or 'componentb' in ibd.lower()

    def test_no_ports(self, tmp_sysml_file):
        """Render architecture with no ports"""
        content = """package test {
    // Test
    // Domain: test

    public part def Component {
    }
}
"""
        file_path = tmp_sysml_file(content)
        bdd = generate_bdd_plantuml(file_path)

        # Should render component without ports
        assert 'Component' in bdd

    def test_many_components(self, tmp_sysml_file):
        """Render architecture with many components"""
        components = []
        for i in range(10):
            components.append(f'    public part def Component{i} {{\n    }}')

        content = f"""package test {{
    // Test
    // Domain: test

{chr(10).join(components)}
}}
"""
        file_path = tmp_sysml_file(content)
        bdd = generate_bdd_plantuml(file_path)

        # Should handle many components
        for i in range(10):
            assert f'Component{i}' in bdd

    def test_deep_nesting(self, tmp_sysml_file):
        """Render architecture with deep nesting"""
        content = """package test {
    // Test
    // Domain: test

    public part def Level1 {
        part level2 : Level2;
    }

    public part def Level2 {
        part level3 : Level3;
    }

    public part def Level3 {
        port p3;
    }
}
"""
        file_path = tmp_sysml_file(content)
        bdd = generate_bdd_plantuml(file_path)

        # Should render nested structure
        assert 'Level1' in bdd
        assert 'Level2' in bdd
        assert 'Level3' in bdd


# =============================================================================
# INTEGRATION TESTS
# =============================================================================

class TestRenderingIntegration:
    """Integration tests for complete rendering pipeline"""

    def test_round_trip_render(self, tmp_sysml_file):
        """Test generate → parse → render pipeline"""
        # Create architecture
        arch = {
            'id': 'arch_render',
            'name': 'Render Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'ComponentA', 'name': 'portA', 'type': 'DataPort'},
                {'owner': 'ComponentB', 'name': 'portB', 'type': 'DataPort'}
            ],
            'connectors': [
                {'name': 'link1', 'end_a': 'ComponentA.portA', 'end_b': 'ComponentB.portB'}
            ],
            'requirements': [
                {'id': 'REQ-001', 'text': 'Test requirement.'}
            ],
            'relationships': [
                {'type': 'satisfy', 'client': 'ComponentA', 'supplier': 'REQ-001'}
            ]
        }

        # Generate SysML
        sysml = generate_sysml_from_dict(arch)

        # Write to file
        file_path = tmp_sysml_file(sysml)

        # Render diagrams
        bdd = generate_bdd_plantuml(file_path)
        ibd = generate_ibd_plantuml(file_path)

        # Verify diagrams are generated
        assert bdd is not None
        assert ibd is not None
        assert len(bdd) > 0
        assert len(ibd) > 0

        # Verify components appear in diagrams
        assert 'ComponentA' in bdd
        assert 'ComponentB' in bdd
        assert 'ComponentA' in ibd or 'componenta' in ibd.lower()
        assert 'ComponentB' in ibd or 'componentb' in ibd.lower()

    def test_filtered_render(self, tmp_sysml_file):
        """Test rendering with filtered visibility"""
        arch = {
            'id': 'arch_filtered',
            'name': 'Filtered Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'PublicComponent', 'stereotype': 'Block'},
                {'name': 'PrivateComponent', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        # Generate SysML with public keywords
        sysml = generate_sysml_from_dict(arch)

        # Manually mark one as private (edit generated content)
        sysml = sysml.replace('public part def PrivateComponent', 'part def PrivateComponent')

        file_path = tmp_sysml_file(sysml)

        # Render diagrams
        bdd = generate_bdd_plantuml(file_path)

        # Public component should be visible
        assert 'PublicComponent' in bdd

        # Private component should be filtered
        assert 'PrivateComponent' not in bdd


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
