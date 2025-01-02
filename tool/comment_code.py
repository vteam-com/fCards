import sys
import subprocess

def comment_file(file_path):
    try:
        # Read Dart source file
        with open(file_path, "r") as f:
            code = f.read()

        # Prepare a prompt for commenting
        prompt = f"Add detailed comments to the following Dart code:\n\n{code}"

        # Call Ollama CLI with the 'run' command to process the code
        process = subprocess.run(
            ["ollama", "run", "llama3.2:1b", "--text", prompt],  # Use 'run' and the correct model
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Check for errors
        if process.returncode != 0:
            raise Exception(f"Ollama error: {process.stderr}")

        # Get the processed code with comments
        commented_code = process.stdout.strip()

        # Overwrite the original file with commented code
        with open(file_path, "w") as f:
            f.write(commented_code)

        print(f"Successfully commented: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 generate_comments.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    comment_file(file_path)
