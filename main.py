from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage # Import message types
from dotenv import load_dotenv
import os
import subprocess
import sys # --- IMPORTED SYS ---
import time  # --- ADDED TIME IMPORT ---
from jsonLoader import parse_json_directory_to_dicts

load_dotenv()


llm = ChatOpenAI(
    api_key=os.getenv("GEMINI_API_KEY"),
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
    model="gemini-2.5-flash",
)

# --- No embeddings needed for this ---

# --- MODIFICATION ---
# Updated prompt to ask for input() instead of sys.argv
prompt = """Your task is to generate a Python solution for the given problem. The solution must read its input from the terminal using the input() function. Your response must contain *only* the Python code. Do not provide any text before or after the code. Do not add explanations, examples, or any markdown like ```python."""
# --- END MODIFICATION ---

# --- No agent needed for this ---


def validate_solution(actual_output: str, expected_output: str) -> bool:
    """
    Compares the actual output from the script to the expected output.
    Strips leading/trailing whitespace for a more robust comparison.
    """
    return actual_output.strip() == expected_output.strip()


def main():
    # --- MODIFICATION: Read path from command line ---
    if len(sys.argv) < 2:
        print("ERROR: Please provide the path to the JSON directory as a command-line argument.")
        print("Usage: python main.py /path/to/your/json/folder")
        sys.exit(1) # Exit the script with an error
    
    json_directory_path = sys.argv[1]
    # --- END MODIFICATION ---

    # load json
    print(f"Loading problems from: {json_directory_path}")
    problems = parse_json_directory_to_dicts(json_directory_path)
    
    print(f"Found {len(problems)} problems to process")
    print(f"Estimated time: {len(problems) * 30} seconds (including delays)")
    print("=" * 50)
    
    # This line isn't used, but doesn't hurt
    # documents = [Document(page_content=str(problem)) for problem in problems]

    for i, problem in enumerate(problems):
        query = problem.get("query", "No query provided.")
        
        # Add retry logic for API calls
        max_retries = 3
        retry_delay = 30  # 30 seconds between retries
        code_response = None
        
        for attempt in range(max_retries):
            try:
                print(f"Processing problem {i+1}/{len(problems)} (attempt {attempt+1}/{max_retries})")
                
                # Use llm.invoke() directly with a list of messages
                response = llm.invoke([
                    SystemMessage(content=prompt),
                    HumanMessage(content=query)
                ])

                # The response from an LLM call is a message object, not a dict
                code_response = response.content
                break  # Success, exit retry loop
                
            except Exception as e:
                print(f"API error on attempt {attempt+1}: {e}")
                if attempt < max_retries - 1:
                    print(f"Waiting {retry_delay} seconds before retry...")
                    time.sleep(retry_delay)
                else:
                    print(f"Failed to process problem {i+1} after {max_retries} attempts. Skipping...")
                    code_response = None
        
        # Skip this problem if we couldn't get a response
        if code_response is None:
            continue
        
        # The clean_code logic is still a good safeguard
        clean_code = code_response.strip().replace(
            "```python", "").replace("```", "").strip()

        # --- ADDED CODE ---
        print(f"--- Generated Code for Solution {i+1} ---")
        print(clean_code)
        print("------------------------------------------")
        # --- END ADDED CODE ---

        solution_path = f"./solutions/solution_{i+1}.py"
        try:
            # Ensure the solutions directory exists
            os.makedirs("./solutions", exist_ok=True) 
            
            with open(solution_path, "w", encoding="utf-8") as f:
                f.write(clean_code)
            print(
                f"Solution for Problem {i+1} written to {solution_path}")

            # --- MODIFICATION ---
            # Get input data from the problem dict
            test_input = problem.get("test_input")
            input_data = None # Default to no input
            
            if test_input is not None:
                if isinstance(test_input, list):
                    # If it's a list, join with newlines for multiple inputs
                    input_data = "\n".join(str(arg) for arg in test_input)
                else:
                    # If it's a single value, just convert to string
                    input_data = str(test_input)
            
            # Construct the command (no args)
            command = ["python", solution_path]
            
            # Now, run the solution file, passing data to stdin
            result = subprocess.run(
                command,
                input=input_data, # Pass data to stdin
                capture_output=True, text=True, timeout=10
            )
            # --- END MODIFICATION ---

            stdout = result.stdout.strip()
            stderr = result.stderr.strip()
            
            # --- VALIDATION LOGIC ---
            if stderr:
                # --- Typo fix: iV+1 changed to i+1 ---
                print(f"--- Error from Solution {i+1} ---")
                print(stderr)
                print("--------------------------------")
                print("--- Validation Result: FAIL (Runtime Error) ---")
            else:
                if stdout:
                    print(f"--- Output from Solution {i+1} ---")
                    print(stdout)
                    print("---------------------------------")
                
                # Now, validate the output
                # Changed to look for "test_output"
                expected_output = problem.get("test_output")
                
                if expected_output is not None:
                    # Convert expected_output to string for safe comparison
                    is_correct = validate_solution(stdout, str(expected_output))
                    print(f"--- Validation Result: {'PASS' if is_correct else 'FAIL'} ---")
                else:
                    print("--- Validation: SKIPPED (no 'expected_output' in problem) ---")
            # --- END VALIDATION LOGIC ---

        except IOError as e:
            print(f"Error writing solution for Problem {i+1}: {e}")
        except subprocess.TimeoutExpired:
            # --- TYPO FIX ---
            print(f"Solution {i+1} timed out during execution.")
            # --- END TYPO FIX ---
        except Exception as e:
            print(f"An error occurred with solution {i+1}: {e}")
        
        # --- RATE LIMITING ---
        # Add longer delay between API calls to avoid rate limiting
        # Skip delay for the last iteration
        if i < len(problems) - 1:
            print(f"Waiting 20 seconds before processing next problem to avoid rate limiting...")
            time.sleep(20)
        # --- END RATE LIMITING ---

    # --- COMPLETION SUMMARY ---
    print("\n" + "=" * 50)
    print("🎉 ALL TASKS COMPLETED!")
    print(f"✅ Processed {len(problems)} problems successfully")
    print(f"📁 Solutions saved to ./solutions/ directory")
    print("🔄 Container will now exit (no auto-restart)")
    print("=" * 50)
    # --- END COMPLETION SUMMARY ---


if __name__ == "__main__":
    main()