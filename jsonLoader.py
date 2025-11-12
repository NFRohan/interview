import json
from pathlib import Path
from typing import List, Dict, Any

def parse_json_directory_to_dicts(directory_path: str) -> List[Dict[str, Any]]:
    """
    Parses all JSON files in a given directory and returns their contents
    as a list of dictionaries.

    Args:
        directory_path: The path to the directory containing JSON files.

    Returns:
        A list of dictionaries, where each dictionary represents the
        content of one JSON file.
    """
    all_file_dicts: List[Dict[str, Any]] = []
    dir_path = Path(directory_path)

    if not dir_path.is_dir():
        print(f"Error: Path '{directory_path}' is not a valid directory.")
        return []

    # Use .glob() to find all files ending in .json
    for file_path in dir_path.glob("*.json"):
        try:
            # Open and load the JSON file
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Append the raw dictionary to the list
            all_file_dicts.append(data)

        except json.JSONDecodeError:
            # This will catch files like 'readme.txt'
            print(f"Warning: Skipping non-JSON file or malformed JSON: {file_path}")
        except IOError as e:
            print(f"Warning: Could not read file {file_path}: {e}")
        except Exception as e:
            print(f"Warning: An unexpected error occurred with file {file_path}: {e}")

    return all_file_dicts

# --- Example Usage ---
if __name__ == "__main__":
    # This assumes you ran `setup_files.py` first
    TEST_DIR = "./json" 
    
    print(f"Parsing JSON files in '{TEST_DIR}'...")
    formatted_dicts = parse_json_directory_to_dicts(TEST_DIR)
    
    print(f"\n--- Found {len(formatted_dicts)} JSON files ---\n")
    print(formatted_dicts)
    
    # # Print the resulting dictionaries
    # for i, file_content in enumerate(formatted_dicts):
    #     print(f"--- Content of File {i+1} ---")
    #     # Pretty-print the dictionary
    #     print(json.dumps(file_content, indent=4))
    #     print()

