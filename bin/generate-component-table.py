"""
This script recursively scans a Salesforce source directory and compiles Markdown tables:
1. A detailed table of all components
2. A summary table showing component types per module

It includes all files found, classifying them by file extension if no Salesforce type is known.

How it works:
- Recursively scans all files in the specified directory (including subdirectories).
- Uses an extended SALESFORCE_METADATA_TYPES mapping to classify files by their extension.
- For files that match a known extension, it removes the extension from the filename for clarity.
- For files that don't match a known extension, uses the file extension as type.
- Uses Git (if available) to determine if a file is "Created" or "Changed". Unmodified files have an empty state.
- Determines the module for each file based on the first subdirectory in its path.
- Counts the number of lines in each file.
- Compiles the collected information into two Markdown tables:
  1. A detailed component table with columns: State, Module, Type, Name, Line Count, and Path
  2. A summary table with component types as rows and modules as columns, showing both line counts and file counts
- Prints usage instructions if no directory argument is provided.
"""

import os
import re
import sys
import subprocess
import datetime
from collections import defaultdict

# Global flag for debug mode
DEBUG = False

def debug(msg):
    """Print debug message if DEBUG mode is enabled"""
    if DEBUG:
        timestamp = datetime.datetime.now().strftime("%H:%M:%S.%f")
        print(f"[DEBUG {timestamp}] {msg}", file=sys.stderr)

# Extended mapping of file extensions to Salesforce metadata types.
# This dictionary maps common Salesforce file extensions to their corresponding metadata types.
SALESFORCE_METADATA_TYPES = {
    # Apex & Visualforce
    ".cls": "ApexClass",
    ".cls-meta.xml": "ApexClass",
    ".trigger": "ApexTrigger",
    ".trigger-meta.xml": "ApexTrigger",
    ".component": "ApexComponent",
    ".component-meta.xml": "ApexComponent",
    ".page": "VisualforcePage",
    ".page-meta.xml": "VisualforcePage",

    # Aura Components
    ".cmp": "AuraComponent",
    ".cmp-meta.xml": "AuraComponent",
    ".evt": "AuraEvent",
    ".evt-meta.xml": "AuraEvent",
    ".app": "AuraApplication",
    ".app-meta.xml": "AuraApplication",
    ".design": "AuraDesign",
    ".design-meta.xml": "AuraDesign",

    # Lightning Web Components (LWC)
    # The -meta.xml file is used to identify Lightning Web Components.
    ".js-meta.xml": "LightningWebComponent",

    # Objects and Fields
    ".object-meta.xml": "CustomObject",
    ".field-meta.xml": "CustomField",

    # Other Metadata Types
    ".tab-meta.xml": "CustomTab",
    ".layout-meta.xml": "Layout",
    ".listView-meta.xml": "ListView",
    ".webLink-meta.xml": "WebLink",
    ".fieldSet-meta.xml": "FieldSet",
    ".profile-meta.xml": "Profile",
    ".permissionset-meta.xml": "PermissionSet",
    ".resource-meta.xml": "StaticResource",
    ".flow-meta.xml": "Flow",
    ".flowDefinition-meta.xml": "FlowDefinition",
    ".email-meta.xml": "EmailTemplate",
    ".report-meta.xml": "Report",
    ".dashboard-meta.xml": "Dashboard",
    ".customSite-meta.xml": "CustomSite",
    ".assignmentRules-meta.xml": "AssignmentRules",
    ".escalationRules-meta.xml": "EscalationRules",
    ".remoteSite-meta.xml": "RemoteSiteSetting",
    ".certificate-meta.xml": "Certificate",
    ".labels-meta.xml": "CustomLabels",
    ".recordType-meta.xml": "RecordType",
    ".compactLayout-meta.xml": "CompactLayout",
    ".connectedApp-meta.xml": "ConnectedApp",
    ".translation-meta.xml": "Translations",
    ".site-meta.xml": "SiteDotCom",
    ".networkBranding-meta.xml": "NetworkBranding",
    ".territory2Rule-meta.xml": "Territory2Rule",
    ".territory2Type-meta.xml": "Territory2Type",
    ".customPermission-meta.xml": "CustomPermission",
    ".quickAction-meta.xml": "QuickAction",
}

def detect_file_state(file_path, base_dir):
    """
    Determines whether the file is newly created, modified, or unchanged using Git.
    
    How it works:
    - Calls 'git status --porcelain' on the file (using its relative path).
    - If the status code starts with "A", returns "Created".
    - If the status code starts with "M", returns "Changed".
    - Otherwise, returns an empty string for unmodified files.
    - If Git is not available or an error occurs, it returns an empty string.
    """
    try:
        rel_path = os.path.relpath(file_path, base_dir)
        git_status = subprocess.run(["git", "status", "--porcelain", rel_path],
                                    capture_output=True, text=True)
        status_code = git_status.stdout.strip()[:2]  # Extract status code (e.g., "A ", "M ")

        if status_code.startswith("A"):
            return "Created"
        elif status_code.startswith("M"):
            return "Changed"
    except Exception:
        pass  # If Git isn't available or an error occurs, assume empty state

    return ""  # Empty state for unmodified files

def determine_module(relative_path):
    """
    Determines the module name based on the first directory in the relative path.
    
    Args:
        relative_path (str): The file path relative to the base directory.
    
    Returns:
        str: The module name (first directory in the path) or "-" if no directory is found.
    """
    parts = relative_path.split(os.sep)
    if len(parts) > 0:
        return parts[0]
    return "-"

def get_file_extension(filename):
    """
    Extracts the file extension from a filename.
    If the file has multiple extensions, returns at most the last two components.
    
    Args:
        filename (str): The name of the file.
    
    Returns:
        str: The file extension(s) or an empty string if none found.
        For example, for file '111.222.abc.xyz', returns 'abc.xyz'.
    """
    # Split the filename by dots
    parts = filename.split('.')
    
    # If the file has a name and at least one extension
    if len(parts) > 1:
        # If multiple extensions exist, take at most the last two
        if len(parts) > 2:
            return '.'.join(parts[-2:])  # Return the last two components
        else:
            return parts[-1]  # Return just the last component
    
    return ""  # No extension found

def count_lines(file_path):
    """
    Counts the number of lines in a file.
    
    Args:
        file_path (str): Path to the file.
    
    Returns:
        int: Number of lines in the file, or 0 if file can't be read.
    """
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            return sum(1 for _ in f)
    except Exception:
        # Return 0 for files that can't be read as text
        return 0

def categorize_files(base_dir):
    """
    Recursively scans the directory and categorizes files.
    
    How it works:
    - Uses os.walk to traverse all subdirectories.
    - For each file, checks if its name ends with any known Salesforce metadata extension.
    - If a match is found, assigns the corresponding type and removes the extension from the name.
    - If no match is found, uses the file extension as the type.
    - Determines the file state using the detect_file_state function.
    - Determines the module using the determine_module function.
    - Counts the number of lines in each file.
    - Collects a tuple (state, module, type, name, line_count, path) for each file.
    """
    file_data = []
    file_count = 0

    for root, _, files in os.walk(base_dir):
        debug(f"Scanning directory: {root}")
        for file in files:
            file_count += 1
            if file_count % 100 == 0:
                debug(f"Processed {file_count} files")
            
            file_path = os.path.join(root, file)
            relative_path = os.path.relpath(file_path, base_dir)
            debug(f"Processing file: {relative_path}")
            
            metadata_type = ""
            stripped_name = file  # Default: use the full filename
            matched_ext = None

            # Try to match with known Salesforce metadata types
            for ext, sf_type in SALESFORCE_METADATA_TYPES.items():
                if file.endswith(ext):
                    metadata_type = sf_type
                    matched_ext = ext
                    break
            
            # If a known extension is found, remove it from the file name for clarity
            if matched_ext:
                stripped_name = file[:-len(matched_ext)]
            # If no known type is found, use the file extension as the type
            elif not metadata_type:
                metadata_type = get_file_extension(file)
            
            state = detect_file_state(file_path, base_dir)
            module = determine_module(relative_path)
            line_count = count_lines(file_path)
            
            # Reordered tuple elements: (state, module, type, name, line_count, path)
            file_data.append((state, module, metadata_type, stripped_name, line_count, relative_path))

    return file_data

def generate_markdown_table(file_data):
    """
    Generates a Markdown table from the file data.
    
    How it works:
    - Creates the header row and a separator row.
    - Iterates over each file entry and creates a table row with columns: 
      State, Module, Type, Name, Line Count, and Path.
    - Joins all rows into a single string representing the Markdown table.
    """
    markdown_table = []
    markdown_table.append("| State       | Module       | Type        | Name         | Line Count | Path                     |")
    markdown_table.append("|-------------|-------------|-------------|--------------|------------|--------------------------|")

    for row in file_data:
        markdown_table.append(f"| {row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]} |")

    return "\n".join(markdown_table)

def generate_summary_table(file_data):
    """
    Generates a summary Markdown table that shows both line counts and file counts for each
    component type per module.
    
    Args:
        file_data: List of tuples with file data (state, module, type, name, line_count, path)
    
    Returns:
        str: A Markdown table with component types as rows and modules as columns,
             showing line counts and file counts in each cell.
    """
    # Structure to hold counts:
    # {type: {module: {"files": count, "lines": count}}}
    type_module_counts = defaultdict(lambda: defaultdict(lambda: {"files": 0, "lines": 0}))
    
    # Get all unique types and modules
    all_types = set()
    all_modules = set()
    
    for _, module, type_name, _, line_count, _ in file_data:
        if type_name:  # Skip empty types
            type_module_counts[type_name][module]["files"] += 1
            type_module_counts[type_name][module]["lines"] += line_count
            all_types.add(type_name)
            all_modules.add(module)
    
    # Sort types and modules for consistent table
    sorted_types = sorted(all_types)
    sorted_modules = sorted(all_modules)
    
    # Add "Summary" as a pseudo-module for totals per type
    sorted_modules.append("Summary")
    
    # Generate the table
    markdown_table = []
    
    # Header row with module names
    header = "| Component Type |"
    for module in sorted_modules:
        header += f" {module} |"
    markdown_table.append(header)
    
    # Separator row
    separator = "|----------------|"
    for _ in sorted_modules:
        separator += "------------|"
    markdown_table.append(separator)
    
    # Data rows for each component type
    for type_name in sorted_types:
        row = f"| {type_name} |"
        
        # Calculate summary for this type across all modules
        type_summary = {"files": 0, "lines": 0}
        for module in sorted_modules[:-1]:  # Exclude "Summary" module
            type_summary["files"] += type_module_counts[type_name][module]["files"]
            type_summary["lines"] += type_module_counts[type_name][module]["lines"]
        
        # Add data for each module
        for module in sorted_modules[:-1]:  # Process all modules except the Summary column
            file_count = type_module_counts[type_name][module]["files"]
            line_count = type_module_counts[type_name][module]["lines"]
            
            if file_count > 0:
                row += f" {line_count} / {file_count} |"
            else:
                row += " - |"
        
        # Add summary column for this type
        row += f" **{type_summary['lines']} / {type_summary['files']}** |"
        
        markdown_table.append(row)
    
    # Add totals row
    totals_row = "| **TOTAL** |"
    
    # Calculate grand total across all types and modules
    grand_total = {"files": 0, "lines": 0}
    
    # First, add totals for each module
    for module in sorted_modules[:-1]:  # Exclude "Summary" module
        module_total = {"files": 0, "lines": 0}
        
        for type_name in sorted_types:
            module_total["files"] += type_module_counts[type_name][module]["files"]
            module_total["lines"] += type_module_counts[type_name][module]["lines"]
        
        # Add to grand total
        grand_total["files"] += module_total["files"]
        grand_total["lines"] += module_total["lines"]
        
        # Add to totals row
        totals_row += f" **{module_total['lines']} / {module_total['files']}** |"
    
    # Add grand total to the summary column
    totals_row += f" **{grand_total['lines']} / {grand_total['files']}** |"
    
    markdown_table.append(totals_row)
    
    return "\n".join(markdown_table)

def ensure_directory_exists(dir_path):
    """
    Creates a directory if it doesn't exist.
    
    Args:
        dir_path (str): Path to the directory.
    """
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)

def print_usage():
    """
    Prints the usage instructions for the script.
    
    How it works:
    - Informs the user how to run the script with the required directory argument.
    """
    print("Usage: python generate-component-table.py <directory>")
    print("Scans a Salesforce source directory and generates Markdown tables.")
    print("Debug: python generate-component-table.py --debug <directory>")

def main():
    """
    Main entry point for the script.
    
    How it works:
    - Checks command-line arguments for a directory.
    - If no valid directory is provided, prints usage instructions and exits.
    - Otherwise, calls categorize_files to gather file data.
    - Generates and prints the detailed component table.
    - Creates a summary table and saves it to docs/component-table-summary.md.
    """
    global DEBUG
    # Check for --debug flag
    if "--debug" in sys.argv:
        DEBUG = True
        sys.argv.remove("--debug")
        debug("Debug mode enabled")
    
    if len(sys.argv) != 2:
        print_usage()
        sys.exit(1)

    base_dir = sys.argv[1]

    if not os.path.isdir(base_dir):
        print(f"Error: Directory '{base_dir}' not found.")
        sys.exit(1)

    debug(f"Starting file scan in {base_dir}")
    file_data = categorize_files(base_dir)
    debug(f"Found {len(file_data)} files")
    
    # Generate and print the detailed component table
    detailed_table = generate_markdown_table(file_data)
    print(detailed_table)
    
    # Generate the summary table and save it to docs/component-table-summary.md
    summary_table = generate_summary_table(file_data)
    
    # Create docs directory if it doesn't exist (using parent directory of base_dir)
    parent_dir = os.path.dirname(os.path.abspath(base_dir))
    docs_dir = os.path.join(parent_dir, "docs")
    ensure_directory_exists(docs_dir)
    
    # Write the summary table to a file
    summary_file_path = os.path.join(docs_dir, "component-table-summary.md")
    debug(f"Writing summary table to {summary_file_path}")
    with open(summary_file_path, 'w') as f:
        f.write("# Component Table Summary\n\n")
        f.write("This table summarizes the number of components by type and module.\n")
        f.write("Each cell shows: LINE COUNT / FILE COUNT\n\n")
        f.write(summary_table)
    
    print(f"\nSummary table written to {summary_file_path}")

if __name__ == "__main__":
    main()
