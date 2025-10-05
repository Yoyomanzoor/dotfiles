#!/usr/bin/env python

import re
import sys
import os
import subprocess
from collections import defaultdict

def parse_sway_config(config_path):
    """
    Parses a sway config file to extract keybindings, modes, and variables
    based on a strict '## Category // Description ##' format, with special
    handling for section headers inside 'mode' blocks.
    """
    try:
        with open(config_path, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: The file '{config_path}' was not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)

    bindings_list = []
    variables = {}
    main_category = "General"
    sub_category = "Uncategorized"
    current_mode = None
    in_mode_block = False

    # Regex for standard headers: ## Category // Description ##
    header_re = re.compile(r'^##\s*(.*?)\s*//\s*(.*?)\s*(//.*?)?##$')
    # Regex for mode-specific headers: ## Description ##
    mode_header_re = re.compile(r'^##\s*(.*?)\s*##$')
    # Regex for mode block start
    mode_start_re = re.compile(r'^mode "([^"]+)"\s*\{')

    for line in lines:
        line = line.strip()
        
        if not line:
            continue

        if line.startswith('set '):
            parts = line.split(maxsplit=2)
            if len(parts) >= 3:
                var_name = parts[1]
                var_value = os.path.expanduser(parts[2].strip().strip('"'))
                variables[var_name] = var_value
            continue

        # --- CONTEXT-AWARE PARSING ---
        
        # Handle end of a mode block
        if line == '}' and in_mode_block:
            current_mode = None
            in_mode_block = False
            main_category = "General"
            sub_category = "Uncategorized"
            continue

        # Handle start of a mode block
        mode_match = mode_start_re.match(line)
        if mode_match:
            current_mode = mode_match.group(1)
            in_mode_block = True
            main_category = current_mode  # The mode name is the main category
            sub_category = "General"      # Default section for the mode
            continue

        # Handle headers, with different logic depending on context
        if line.startswith('##'):
            if in_mode_block:
                # Inside a mode, the header defines the section (sub_category)
                mode_header_match = mode_header_re.match(line)
                if mode_header_match:
                    content = mode_header_match.group(1).strip()
                    # Clean up content, replacing // for display
                    sub_category = ' - '.join(part.strip() for part in content.split('//'))
            else:
                # Outside a mode, use the standard Category // Description format
                header_match = header_re.match(line)
                if header_match:
                    main_category = header_match.group(1).strip()
                    sub_category = header_match.group(2).strip()
            continue # Skip to next line after processing a header

        # Ignore commented out lines that aren't headers
        if line.startswith('#'):
            continue
        
        # Parse keybindings
        if line.startswith('bindsym'):
            # Split the line into words to handle flags like --locked
            all_parts = line.split()
            
            # Find the index of the key combo (the first word after 'bindsym' that doesn't start with '--')
            key_index = -1
            for i, part in enumerate(all_parts):
                if i > 0 and not part.startswith('--'):
                    key_index = i
                    break
            
            # Ensure a key and an action exist
            if key_index != -1 and len(all_parts) > key_index + 1:
                key_combo_raw = all_parts[key_index]
                # The rest of the line is the action
                action_raw = ' '.join(all_parts[key_index+1:])
                
                key_combo = key_combo_raw.replace('$mod', ' ').replace('$alt', 'Alt').replace('+', ' + ')
                action = action_raw
                bindings_list.append({
                    'key': key_combo, 
                    'action': action,
                    'main_category': main_category,
                    'sub_category': sub_category,
                    'mode': current_mode 
                })

    return bindings_list, variables

def show_in_rofi(all_bindings, variables):
    """Formats the cheatsheet, displays it in rofi, and executes the selection."""
    if not all_bindings:
        print("No keybinding sections found matching the required format in the config file.", file=sys.stderr)
        return

    command_map = {}
    rofi_input_lines = []
    
    max_key_len = max(len(b['key']) for b in all_bindings) if all_bindings else 0

    for item in all_bindings:
        key = item['key']
        action = item['action']
        sub_category = item['sub_category']
        main_category = item['main_category']
        mode = item.get('mode')
        
        display_action = action
        for var, val in variables.items():
            display_action = display_action.replace(var, val)

        padding = ' ' * (max_key_len - len(key))
        
        # Display as [Section] [Category]
        categories = f"<i>[{sub_category}] [{main_category}]</i>"

        display_line = (f"{key}{padding}  →  {display_action}  "
                        f"<span weight='light' size='small'>{categories}</span>")
        rofi_input_lines.append(display_line)
        
        command_map[display_line] = {'action': action, 'mode': mode}

    rofi_config_path = os.path.expanduser("~/.config/rofi/rose-pine.rasi")
    rofi_command = [
        "rofi", "-dmenu", "-case-smart", "-p", "Sway Keybindings ",
        "-markup-rows", "-i",
        "-theme-str", 'window {width: 65%;}',
        "-theme-str", 'listview {lines: 20;}'
    ]
    if os.path.exists(rofi_config_path):
        rofi_command.extend(["-config", rofi_config_path])
    
    try:
        rofi_process = subprocess.run(
            rofi_command,
            input="\n".join(rofi_input_lines),
            text=True,
            capture_output=True,
            check=False 
        )

        selected_line = rofi_process.stdout.strip()

        if selected_line and selected_line in command_map:
            command_info = command_map[selected_line]
            raw_command = command_info['action']
            mode_name = command_info['mode']
            
            final_command = raw_command
            for var_name, var_value in variables.items():
                final_command = final_command.replace(var_name, var_value)

            if mode_name:
                # For mode commands, wrap the action with mode enter/exit
                subprocess.run(["swaymsg", f'mode "{mode_name}"'], check=False)
                subprocess.run(["swaymsg", final_command], check=False)
                subprocess.run(["swaymsg", 'mode "default"'], check=False)
            else:
                # For regular commands, execute directly
                subprocess.run(["swaymsg", final_command], check=False)

    except FileNotFoundError:
        print("Error: 'rofi' is not installed or not in PATH.", file=sys.stderr)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} /path/to/your/sway/config", file=sys.stderr)
        sys.exit(1)
        
    config_file = sys.argv[1]
    parsed_bindings, parsed_variables = parse_sway_config(config_file)
    show_in_rofi(parsed_bindings, parsed_variables)


