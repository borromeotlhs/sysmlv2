# SPA Dual Format Support - Summary

The SPA now supports both JSON IR and SysML v2 textual formats!

## What Changed

✅ **SysML v2 Parser** - New `spa/sysml_parser.py` parses .sysml files
✅ **Automatic Format Detection** - Server detects .json vs .sysml and handles both
✅ **PlantUML from Both** - BDD/IBD diagrams work with either format
✅ **File Tree Integration** - .sysml files shown as clickable architecture files
✅ **Format Indicator** - UI shows "JSON IR" or "SysML v2 Textual" format

## Quick Start

```bash
# 1. Generate architectures (if not already done)
python3 scripts/generate_varied_architectures.py

# 2. Convert to SysML v2
python3 scripts/json_to_sysml.py

# 3. Start SPA
python3 spa/server.py --host 127.0.0.1 --port 8081

# 4. Open browser: http://127.0.0.1:8081
#    - Navigate to outputs/sysml/ in file tree
#    - Click any .sysml file
#    - View Text/BDD/IBD tabs just like JSON files!
```

## Usage

### In the SPA

1. **Load JSON architecture**
   - Navigate to `data/architectures/`
   - Click any `.json` file
   - Works as before

2. **Load SysML architecture** (NEW!)
   - Navigate to `outputs/sysml/`
   - Click any `.sysml` file
   - Automatically parsed and displayed
   - Same tabs: Text/BDD/IBD

3. **Create training pairs**
   - Works with both formats
   - Click architecture → write prompt → add pair
   - Save to `data/pairs/`

### Format Comparison

| Format | Extension | Location | Use Case |
|--------|-----------|----------|----------|
| JSON IR | `.json` | `data/architectures/` | Generation, manipulation |
| SysML v2 | `.sysml` | `outputs/sysml/` | Training, validation |

### Convert Between Formats

**JSON → SysML:**
```bash
python3 scripts/json_to_sysml.py
```

**SysML → JSON (automatic):**
- Server parses .sysml on load
- Converts to JSON IR in memory
- No file created

## Architecture Files

Both formats represent the same architecture information:

**JSON IR** (`data/architectures/arch_000001.json`):
```json
{
  "id": "arch_000001",
  "blocks": [{"name": "Computer", "stereotype": "Block"}],
  "proxy_ports": [{"owner": "Computer", "name": "port", "type": "IF"}],
  "requirements": [{"id": "REQ-001", "text": "System shall..."}]
}
```

**SysML v2** (`outputs/sysml/arch_000001.sysml`):
```sysml
package arch_000001 {
  interface def IF;
  
  part def Computer {
    port port : IF;
  }
  
  requirement <'REQ-001'> {
    doc /* System shall... */
  }
}
```

## PlantUML Diagrams

Both formats generate identical diagrams:
1. Load file (.json or .sysml)
2. Parse to JSON IR structure
3. Generate PlantUML from IR
4. Render via public server

## Training Recommendation

**Train on .sysml files** (not JSON):
- SysML v2 is the actual modeling language
- Can validate with official tools
- Works in SysML v2 ecosystem
- JSON is just intermediate format

## Validation

Test SysML files with official validator:
```bash
# Clone validator
git clone https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation.git

# Validate
cd SysML-v2-Pilot-Implementation
./gradlew run --args="../outputs/sysml/arch_000001.sysml"
```

## Files

**New:**
- `spa/sysml_parser.py` - SysML v2 parser
- `docs/DUAL_FORMAT_SUPPORT.md` - Detailed documentation
- `README_DUAL_FORMAT.md` - This file

**Modified:**
- `spa/server.py` - Added format detection and parser integration
- `spa/static/app.js` - Recognizes .sysml files, shows format

**Unchanged:**
- PlantUML generation (works on JSON IR)
- Pair creation workflow
- File tree navigation
- UI/styling

## Testing

```bash
# Test parser
cd spa && python3 -c "
from sysml_parser import parse_sysml_to_json
from pathlib import Path
result = parse_sysml_to_json(Path('../outputs/sysml/arch_000001.sysml').read_text())
print(f'✓ Parsed: {result[\"id\"]}')
"

# Test SPA
python3 spa/server.py --host 127.0.0.1 --port 8081
# Open http://127.0.0.1:8081
# Click .sysml file in tree → should load and display
```

## Documentation

- **JSON IR Schema**: `docs/JSON_IR_SCHEMA.md`
- **Dual Format Details**: `docs/DUAL_FORMAT_SUPPORT.md`
- **Quick Start**: `docs/QUICKSTART_SYSML.md`

## Next Steps

1. ✅ Generate architectures: `generate_varied_architectures.py`
2. ✅ Convert to SysML: `json_to_sysml.py`
3. ✅ Browse in SPA: Load .sysml files
4. ✅ View diagrams: BDD/IBD tabs work
5. 📝 Create pairs: Add prompts for training
6. 🎓 Train adapter: Use .sysml files as corpus
