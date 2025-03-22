#!/usr/bin/env python3
import os
import re
import json
from flask import Flask, render_template_string, request, jsonify

############################
# Configuration / Globals
############################
app = Flask(__name__)

DEBUG = False  # Set this to True to see debug logs

def dprint(*args):
    """If DEBUG=True, prints messages."""
    if DEBUG:
        print(*args)

# Base directory
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
JSON_FILE = os.path.join(BASE_DIR, "npc_heroes.json")
KV_FILE = os.path.join(BASE_DIR, "pak02_dir", "scripts", "npc", "npc_heroes.txt")

# The editable attributes (columns).
# Includes original 7 plus the extra 6 from your last request.
ATTRIBUTES = [
    "AttributePrimary",
    "AttributeBaseStrength",
    "AttributeStrengthGain",
    "AttributeBaseIntelligence",
    "AttributeIntelligenceGain",
    "AttributeBaseAgility",
    "AttributeAgilityGain",
    "ArmorPhysical",
    "MagicalResistance",
    "BaseAttackSpeed",
    "AttackDamageMin",
    "AttackDamageMax",
    "AttackRate"
]

# Friendly display for "AttributePrimary"
ATTRIBUTE_PRIMARY_MAPPING = {
    "DOTA_ATTRIBUTE_STRENGTH": "STRENGTH",
    "DOTA_ATTRIBUTE_AGILITY": "AGILITY",
    "DOTA_ATTRIBUTE_INTELLECT": "INTELLECT",
    "DOTA_ATTRIBUTE_ALL": "ALL"
}

# Column header mapping for user-friendly table headings
COLUMN_HEADER_MAPPING = {
    "AttributePrimary": "Primary",
    "AttributeBaseStrength": "Base STR",
    "AttributeStrengthGain": "STR Gain",
    "AttributeBaseIntelligence": "Base INT",
    "AttributeIntelligenceGain": "INT Gain",
    "AttributeBaseAgility": "Base AGI",
    "AttributeAgilityGain": "AGI Gain",
    "ArmorPhysical": "Armor",
    "MagicalResistance": "Magic Res",
    "BaseAttackSpeed": "Base AS",
    "AttackDamageMin": "DMG",
    "AttackDamageMax": "DMG Variance",
    "AttackRate": "Attack Rate"
}

############################
# Simple KeyValue parser
############################
def tokenize(text):
    # Remove line comments starting with //
    text = re.sub(r'//.*', '', text)
    pattern = r'"([^"]*)"|(\{)|(\})'
    tokens = []
    for match in re.finditer(pattern, text):
        if match.group(1) is not None:
            tokens.append(match.group(1))
        elif match.group(2) is not None:
            tokens.append('{')
        elif match.group(3) is not None:
            tokens.append('}')
    return tokens

def parse_kv_tokens(tokens, i=0):
    result = {}
    while i < len(tokens):
        token = tokens[i]
        if token == '}':
            return result, i + 1
        key = token
        i += 1
        if i < len(tokens) and tokens[i] == '{':
            i += 1
            value, i = parse_kv_tokens(tokens, i)
            result[key] = value
        else:
            if i < len(tokens):
                value = tokens[i]
                i += 1
                result[key] = value
    return result, i

def parse_kv(text):
    tokens = tokenize(text)
    parsed, _ = parse_kv_tokens(tokens)
    return parsed

############################
# JSON load/save
############################
def save_json(data):
    with open(JSON_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)

def load_json():
    if os.path.exists(JSON_FILE):
        with open(JSON_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            if data:
                return data
    return {}

############################
# Derived Stats:
#  * Strength, Agility, Intelligence at level 30
#  * DPS at Max Level (read-only display, computed from AttackDamageMin, AttackDamageMax, AttackRate)
############################
def compute_derived(hero_data):
    # Strength/Agility/Int at 30
    try:
        base_str = float(hero_data.get("AttributeBaseStrength", "0"))
        gain_str = float(hero_data.get("AttributeStrengthGain", "0"))
        base_int = float(hero_data.get("AttributeBaseIntelligence", "0"))
        gain_int = float(hero_data.get("AttributeIntelligenceGain", "0"))
        base_agi = float(hero_data.get("AttributeBaseAgility", "0"))
        gain_agi = float(hero_data.get("AttributeAgilityGain", "0"))
    except ValueError:
        base_str = gain_str = base_int = gain_int = base_agi = gain_agi = 0.0

    # Calculate level 30 attributes
    strength30 = round(base_str + 29 * gain_str, 2)
    agility30 = round(base_agi + 29 * gain_agi, 2)
    int30 = round(base_int + 29 * gain_int, 2)
    
    # Calculate total attributes at max level
    total_attributes = round(strength30 + agility30 + int30, 2)

    # DPS calculation including primary attribute bonus
    try:
        dmg_min = float(hero_data.get("AttackDamageMin", "0"))
        dmg_max = float(hero_data.get("AttackDamageMax", "0"))
        attack_rate = float(hero_data.get("AttackRate", "0"))
        primary_attr = hero_data.get("AttributePrimary", "")
        
        # Calculate attribute bonus damage for level 30
        attr_bonus_30 = 0
        # Calculate attribute bonus damage for level 1
        attr_bonus_1 = 0
        
        if primary_attr == "DOTA_ATTRIBUTE_STRENGTH":
            attr_bonus_30 = strength30
            attr_bonus_1 = base_str
        elif primary_attr == "DOTA_ATTRIBUTE_AGILITY":
            attr_bonus_30 = agility30
            attr_bonus_1 = base_agi
        elif primary_attr == "DOTA_ATTRIBUTE_INTELLECT":
            attr_bonus_30 = int30
            attr_bonus_1 = base_int
        elif primary_attr == "DOTA_ATTRIBUTE_ALL":
            # For ALL, sum all attributes and multiply by 0.45
            attr_bonus_30 = (strength30 + agility30 + int30) * 0.45
            attr_bonus_1 = (base_str + base_agi + base_int) * 0.45
        
        # Calculate average base damage
        avg_base_dmg = (dmg_min + dmg_max) / 2
        
        # Total damage at level 30 and 1
        total_dmg_30 = avg_base_dmg + attr_bonus_30
        total_dmg_1 = avg_base_dmg + attr_bonus_1
        
        # Calculate DPS for level 30 with attack speed
        if attack_rate > 0:
            attacks_per_second = 1.7 / attack_rate
            dps_30 = round(total_dmg_30 * attacks_per_second, 2)
        else:
            dps_30 = 0.0
            
        # For level 1, just use the total damage without attack speed
        dps_1 = round(total_dmg_1, 2)
            
    except (ValueError, ZeroDivisionError):
        dps_30 = dps_1 = 0.0

    return {
        "Strength": strength30,
        "Agility": agility30,
        "Intelligence": int30,
        "TotalAttributes": total_attributes,
        "DPS": dps_30,
        "DPS_Level1": dps_1
    }

############################
# Data loading logic
############################
def load_data():
    # 1) load JSON if present
    data = load_json()
    if data:
        dprint("Loaded data from JSON.")
        return data
    # 2) else parse KV
    dprint("JSON empty or missing; parse KV.")
    if os.path.exists(KV_FILE):
        with open(KV_FILE, "r", encoding="utf-8") as f:
            text = f.read()
        kv_data = parse_kv(text)
        heroes = kv_data.get("DOTAHeroes", {})
        out = {}
        for hero, block in heroes.items():
            if not isinstance(block, dict):
                continue
            hero_data = {}
            for key in ATTRIBUTES:
                hero_data[key] = block.get(key, "")
            if any(hero_data.values()):
                out[hero] = hero_data
        if out:
            dprint("Found heroes in KV.")
            save_json(out)
            return out
    dprint("No data found. Creating sample hero.")
    # 3) If still no data, create a sample hero
    sample = {
        "npc_dota_hero_sample": {
            "AttributePrimary": "DOTA_ATTRIBUTE_STRENGTH",
            "AttributeBaseStrength": "20",
            "AttributeStrengthGain": "2.5",
            "AttributeBaseIntelligence": "15",
            "AttributeIntelligenceGain": "1.5",
            "AttributeBaseAgility": "18",
            "AttributeAgilityGain": "2.0",
            "ArmorPhysical": "1",
            "MagicalResistance": "25",
            "BaseAttackSpeed": "100",
            "AttackDamageMin": "10",
            "AttackDamageMax": "14",
            "AttackRate": "1.500000"
        }
    }
    save_json(sample)
    return sample

############################
# The line-based KV update
############################
def process_hero_attributes(hero, lines_in_block, hero_indent, data):
    dprint(f"Processing hero block: {hero}")
    existing_keys = set()
    hero_vals = data.get(hero, {})
    updated = []
    i = 0
    line_attr_pattern = re.compile(r'^(\s*)"([^"]+)"\s+"([^"]*)"\s*$')
    block_start_pattern = re.compile(r'^(\s*)"([^"]+)"\s*$')

    while i < len(lines_in_block):
        line = lines_in_block[i]
        
        # Check if this line starts a block
        is_block_start = False
        if i < len(lines_in_block) - 1:
            current_line = block_start_pattern.match(line)
            next_line = lines_in_block[i + 1]
            if current_line and "{" in next_line:
                is_block_start = True
                block_key = current_line.group(2)
                updated.append(line)
                updated.append(next_line)
                i += 2
                
                # Skip the entire block
                nesting = 1
                while i < len(lines_in_block) and nesting > 0:
                    if "{" in lines_in_block[i]:
                        nesting += 1
                    if "}" in lines_in_block[i]:
                        nesting -= 1
                    updated.append(lines_in_block[i])
                    i += 1
                continue

        # Normal attribute line
        if not is_block_start:
            m = line_attr_pattern.match(line)
            if m:
                key = m.group(2)
                if key in ATTRIBUTES:
                    existing_keys.add(key)
                    indent = m.group(1)
                    new_val = hero_vals.get(key, m.group(3))
                    new_line = f'{indent}"{key}"\t\t"{new_val}"\n'
                    updated.append(new_line)
                else:
                    updated.append(line)
                i += 1
            else:
                updated.append(line)
                i += 1

    # Add missing attributes at the end, but before any blocks
    missing_keys = set(ATTRIBUTES) - existing_keys
    if missing_keys:
        # Find position before first block
        insert_pos = 0
        for i, line in enumerate(updated):
            if block_start_pattern.match(line) and i + 1 < len(updated) and "{" in updated[i + 1]:
                insert_pos = i
                break
            if i == len(updated) - 1:
                insert_pos = len(updated)

        # Use consistent indentation
        guess_indent = hero_indent + "\t"
        for ln in updated:
            mm = line_attr_pattern.match(ln)
            if mm and mm.group(2) in ATTRIBUTES:
                guess_indent = mm.group(1)
                break

        # Insert missing attributes
        new_lines = []
        for k in sorted(missing_keys):
            v = hero_vals.get(k, "")
            new_line = f'{guess_indent}"{k}"\t\t"{v}"\n'
            new_lines.append(new_line)
        
        updated = updated[:insert_pos] + new_lines + updated[insert_pos:]

    return updated

def process_heroes_block(sublines, indent, data):
    """
    Process lines inside "DOTAHeroes" to find hero definitions:
    "npc_dota_hero_xxx"
    {
       ...
    }
    """
    i = 0
    out_lines = []
    n = len(sublines)
    while i < n:
        line = sublines[i]
        # Attempt to match a hero definition line
        m = re.match(r'^(\s*)"([^"]+)"\s*(\{)?\s*$', line)
        if m:
            local_indent = m.group(1)
            hero_key = m.group(2)
            brace_same_line = bool(m.group(3))

            out_lines.append(line)
            i += 1
            if brace_same_line:
                # gather lines until we see matching brace
                block_lines = []
                closing_regex = r'^' + re.escape(local_indent) + r'\}\s*$'
                while i < n:
                    if re.match(closing_regex, sublines[i]):
                        dprint(f" Found closing brace for hero {hero_key}")
                        updated_block = process_hero_attributes(hero_key, block_lines, local_indent, data)
                        out_lines.extend(updated_block)
                        out_lines.append(sublines[i])
                        i += 1
                        break
                    else:
                        block_lines.append(sublines[i])
                        i += 1
            else:
                # next line might be brace
                if i < n and re.match(r'^\s*\{\s*$', sublines[i]):
                    out_lines.append(sublines[i])
                    i += 1
                    block_lines = []
                    closing_regex = r'^' + re.escape(local_indent) + r'\}\s*$'
                    while i < n:
                        if re.match(closing_regex, sublines[i]):
                            dprint(f" Found closing brace for hero {hero_key}")
                            updated_block = process_hero_attributes(hero_key, block_lines, local_indent, data)
                            out_lines.extend(updated_block)
                            out_lines.append(sublines[i])
                            i += 1
                            break
                        else:
                            block_lines.append(sublines[i])
                            i += 1
                else:
                    dprint(f"Hero {hero_key} missing brace? skipping block updates.")
            continue
        else:
            out_lines.append(line)
            i += 1
    return out_lines

def update_kv_file(data):
    """
    1) Find line for "DOTAHeroes"
    2) Process that block to find each hero block, update attributes
    """
    if not os.path.exists(KV_FILE):
        dprint("No KV file, cannot update.")
        return

    # Read the file with 'r' mode first to get existing content
    with open(KV_FILE, "r", encoding="utf-8") as f:
        lines = f.readlines()

    # Process the lines
    new_lines = []
    i = 0
    n = len(lines)
    pat_heroes = re.compile(r'^(\s*)"DOTAHeroes"\s*(\{)?\s*$')

    while i < n:
        line = lines[i]
        m = pat_heroes.match(line)
        if m:
            dprint("Found top-level DOTAHeroes line.")
            indent = m.group(1)
            brace_same = bool(m.group(2))
            new_lines.append(line)
            i += 1
            if brace_same:
                sublines = []
                close_regex = r'^' + re.escape(indent) + r'\}\s*$'
                while i < n:
                    if re.match(close_regex, lines[i]):
                        dprint(" Found closing brace for DOTAHeroes.")
                        block_updated = process_heroes_block(sublines, indent, data)
                        new_lines.extend(block_updated)
                        new_lines.append(lines[i])
                        i += 1
                        break
                    else:
                        sublines.append(lines[i])
                        i += 1
            else:
                if i < n and re.match(r'^\s*\{\s*$', lines[i]):
                    new_lines.append(lines[i])
                    i += 1
                    sublines = []
                    close_regex = r'^' + re.escape(indent) + r'\}\s*$'
                    while i < n:
                        if re.match(close_regex, lines[i]):
                            dprint(" Found closing brace for DOTAHeroes.")
                            block_updated = process_heroes_block(sublines, indent, data)
                            new_lines.extend(block_updated)
                            new_lines.append(lines[i])
                            i += 1
                            break
                        else:
                            sublines.append(lines[i])
                            i += 1
                else:
                    dprint("DOTAHeroes found but no brace? skipping updates.")
            continue
        else:
            new_lines.append(line)
            i += 1

    # Write back to file with 'w' mode
    with open(KV_FILE, "w", encoding="utf-8", newline='') as f:
        f.writelines(new_lines)

def sync_kv_file(data):
    if not os.path.exists(KV_FILE):
        dprint("No KV file, skipping sync.")
        return
    with open(KV_FILE, "r", encoding="utf-8") as f:
        text = f.read()
    kv_data = parse_kv(text)
    if "DOTAHeroes" not in kv_data:
        dprint("No DOTAHeroes block in KV, skipping sync.")
        return
    kv_heroes = kv_data["DOTAHeroes"]
    out_of_sync = False
    for hero, hero_vals in data.items():
        if hero not in kv_heroes or not isinstance(kv_heroes[hero], dict):
            dprint(f"Hero {hero} missing from KV or not a dict => out of sync.")
            out_of_sync = True
            break
        for k in ATTRIBUTES:
            if kv_heroes[hero].get(k, "") != hero_vals.get(k, ""):
                dprint(f"Out-of-sync: {hero}, key {k}")
                out_of_sync = True
                break
        if out_of_sync:
            break
    if out_of_sync:
        dprint("KV out of sync => calling update_kv_file.")
        update_kv_file(data)
    else:
        dprint("KV is in sync with JSON.")

############################
# Flask app
############################
app = Flask(__name__)

data = load_data()
sync_kv_file(data)

# Add this near the other mapping constants at the top
def format_hero_key(hero_key):
    """Transform npc_dota_hero_XXX to XXX"""
    prefix = "npc_dota_hero_"
    if hero_key.startswith(prefix):
        return hero_key[len(prefix):]
    return hero_key

# Update the INDEX_HTML template string - find the table row that shows hero data and modify the hero cell
INDEX_HTML = """
<!DOCTYPE html>
<html>
<head>
  <title>NPC Heroes Editor</title>
  <style>
    table {
      border: 1px solid #ccc;
      border-collapse: collapse;
      width: 100%;
      table-layout: fixed;
    }
    th, td {
      border: 1px solid #ccc;
      padding: 6px 4px;
      text-align: left;
      white-space: normal;
      word-wrap: break-word;
      min-width: 100px;
      max-width: 150px;
      overflow: hidden;
      font-size: 13px;
      cursor: pointer;
    }
    input, select {
      width: 100%;
      box-sizing: border-box;
      font-size: 13px;
    }
    .readonly {
      background-color: #f0f0f0;
      cursor: default;
    }
  </style>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
  <h1>NPC Heroes Editor</h1>
  <table id="heroTable">
    <thead>
      <tr>
        <th>Hero Key</th>
        {% for attr in attributes %}
          <th>{{ column_mapping[attr] }}</th>
        {% endfor %}
        <th>Strength at 30</th>
        <th>Agility at 30</th>
        <th>Intelligence at 30</th>
        <th>Attributes at Max Level</th>
        <th>DPS at Max Level</th>
        <th>DMG Level 1</th>
      </tr>
    </thead>
    <tbody>
      {% for hero, attrs in data.items() %}
      <tr>
        <td>{{ format_hero_key(hero) }}</td>
        {% for attr in attributes %}
          <td>
            {% if attr == "AttributePrimary" %}
              <select data-hero="{{ hero }}" data-attr="{{ attr }}">
                {% for key, label in primary_mapping.items() %}
                  <option value="{{ key }}" {% if attrs.get(attr, "") == key %}selected{% endif %}>
                    {{ label }}
                  </option>
                {% endfor %}
              </select>
            {% elif attr == "AttackDamageMin" %}
              {% set dmg_min = attrs.get("AttackDamageMin", "0")|float|round|int %}
              <input type="text" 
                     data-hero="{{ hero }}" 
                     data-attr="{{ attr }}" 
                     value="{{ dmg_min }}"
                     class="dmg-base"
                     data-original="{{ dmg_min }}">
            {% elif attr == "AttackDamageMax" %}
              {% set dmg_min = attrs.get("AttackDamageMin", "0")|float|round|int %}
              {% set dmg_max = attrs.get("AttackDamageMax", "0")|float|round|int %}
              {% set variance = dmg_max - dmg_min %}
              <input type="text" 
                     data-hero="{{ hero }}" 
                     data-attr="{{ attr }}" 
                     value="{{ variance }}"
                     class="dmg-variance"
                     data-original="{{ dmg_max }}">
            {% else %}
              <input type="text" data-hero="{{ hero }}" data-attr="{{ attr }}" value="{{ attrs.get(attr, '') }}">
            {% endif %}
          </td>
        {% endfor %}
        <td class="readonly">{{ computed[hero]["Strength"] }}</td>
        <td class="readonly">{{ computed[hero]["Agility"] }}</td>
        <td class="readonly">{{ computed[hero]["Intelligence"] }}</td>
        <td class="readonly">{{ computed[hero]["TotalAttributes"] }}</td>
        <td class="readonly">{{ computed[hero]["DPS"] }}</td>
        <td class="readonly">{{ computed[hero]["DPS_Level1"] }}</td>
      </tr>
      {% endfor %}
    </tbody>
  </table>
  
  <script>
    function getCellValue(cell) {
      var input = cell.querySelector('input, select');
      if (input) {
        if (input.classList.contains('dmg-variance')) {
          // For variance column, sort by the actual variance value
          return parseFloat(input.value) || 0;
        } else if (input.classList.contains('dmg-base')) {
          // For base damage column, sort by the base value
          return parseFloat(input.value) || 0;
        }
        return input.value.trim();
      }
      return cell.innerText.trim();
    }
    
    var sortDirections = {};
    
    function sortTable(colIndex, skipSaveState) {
      var table = document.getElementById("heroTable");
      var tbody = table.tBodies[0];
      var rows = Array.from(tbody.rows);
      
      // Get or toggle sort direction
      var asc = sortDirections[colIndex] === undefined ? true : !sortDirections[colIndex];
      sortDirections[colIndex] = asc;
      
      // Save sort state if not skipped
      if (!skipSaveState) {
        localStorage.setItem('sortColumn', colIndex);
        localStorage.setItem('sortDirection', asc ? 'asc' : 'desc');
      }
      
      rows.sort(function(a, b) {
        var aText = getCellValue(a.cells[colIndex]);
        var bText = getCellValue(b.cells[colIndex]);
        var aNum = parseFloat(aText);
        var bNum = parseFloat(bText);
        if (!isNaN(aNum) && !isNaN(bNum)) {
          return asc ? aNum - bNum : bNum - aNum;
        } else {
          return asc ? aText.localeCompare(bText) : bText.localeCompare(aText);
        }
      });
      
      while (tbody.firstChild) {
        tbody.removeChild(tbody.firstChild);
      }
      rows.forEach(function(row) {
        tbody.appendChild(row);
      });
    }
    
    $(document).ready(function(){
      // Apply saved sort on page load
      var savedColumn = localStorage.getItem('sortColumn');
      var savedDirection = localStorage.getItem('sortDirection');
      if (savedColumn !== null) {
        sortDirections[savedColumn] = savedDirection !== 'asc';  // Set opposite so it toggles to correct direction
        sortTable(parseInt(savedColumn));
      }
      
      $("#heroTable thead th").click(function(){
        var colIndex = $(this).index();
        sortTable(colIndex);
      });
      
      $("input, select").on("change", function(){
        var hero = $(this).data("hero");
        var attr = $(this).data("attr");
        var value = $(this).val();
        $.ajax({
          url: "/update",
          method: "POST",
          data: JSON.stringify({hero: hero, attr: attr, value: value}),
          contentType: "application/json",
          success: function(response) {
            console.log("Updated: " + hero + " - " + attr + " = " + value);
            // Reload page but maintain sort
            location.reload();
          }
        });
      });

      // Special handling for damage inputs
      $('.dmg-base, .dmg-variance').on("change", function() {
        var $this = $(this);
        var hero = $this.data("hero");
        var value = parseFloat($this.val()) || 0;
        
        if ($this.hasClass('dmg-base')) {
          // When base damage changes, update both min and variance displays
          var $variance = $this.closest('tr').find('.dmg-variance');
          var variance = parseFloat($variance.val()) || 0;
          var newMax = value + variance;
          
          // Send both updates in a single request
          $.ajax({
            url: "/update_damage",
            method: "POST",
            data: JSON.stringify({
              hero: hero,
              min: value.toString(),
              max: newMax.toString()
            }),
            contentType: "application/json",
            success: function() {
              location.reload();
            }
          });
        } else if ($this.hasClass('dmg-variance')) {
          // When variance changes, calculate new max from base + variance
          var $base = $this.closest('tr').find('.dmg-base');
          var base = parseFloat($base.val()) || 0;
          var newMax = base + value;
          
          $.ajax({
            url: "/update",
            method: "POST",
            data: JSON.stringify({
              hero: hero, 
              attr: "AttackDamageMax", 
              value: newMax.toString()
            }),
            contentType: "application/json",
            success: function() {
              location.reload();
            }
          });
        }
      });
    });
  </script>
</body>
</html>
"""

@app.route("/")
def index():
    computed_dict = {}
    for hero, attrs in data.items():
        computed_dict[hero] = compute_derived(attrs)
    return render_template_string(
        INDEX_HTML,
        data=data,
        attributes=ATTRIBUTES,
        column_mapping=COLUMN_HEADER_MAPPING,
        primary_mapping=ATTRIBUTE_PRIMARY_MAPPING,
        computed=computed_dict,
        format_hero_key=format_hero_key
    )

@app.route("/update", methods=["POST"])
def update():
    req = request.get_json()
    hero = req.get("hero")
    attr = req.get("attr")
    value = req.get("value")

    # Update in-memory JSON data
    if hero not in data:
        data[hero] = {}
    data[hero][attr] = value
    save_json(data)

    # Then sync that to the KV file
    dprint(f"Ajax update => {hero}.{attr} = {value}")
    update_kv_file(data)

    return jsonify({"status": "success"})

# Add a new route to handle damage updates
@app.route("/update_damage", methods=["POST"])
def update_damage():
    req = request.get_json()
    hero = req.get("hero")
    min_dmg = req.get("min")
    max_dmg = req.get("max")

    if hero not in data:
        data[hero] = {}
    
    # Update both values at once
    data[hero]["AttackDamageMin"] = min_dmg
    data[hero]["AttackDamageMax"] = max_dmg
    
    save_json(data)
    update_kv_file(data)

    return jsonify({"status": "success"})

if __name__ == "__main__":
    app.run(port=1001)