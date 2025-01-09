import os
import subprocess

# Define paths
scripts_dir = "./scripts"  # Replace with your scripts directory
succeeded_file = "./succeeded"
fails_file = "./fails"

# Ensure log files exist
open(succeeded_file, 'a').close()
open(fails_file, 'a').close()

# Function to extract APP name from a script
def get_app_name(script_path):
    try:
        with open(script_path, 'r') as file:
            for line in file:
                if line.startswith("APP="):
                    return line.split("=", 1)[1].strip().strip('"')
    except Exception as e:
        print(f"Error reading {script_path}: {e}")
    return None

# Function to execute a script
def execute_script(script_path):
    try:
        result = subprocess.run(["bash", script_path], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True, result.stdout.decode()
    except subprocess.CalledProcessError as e:
        return False, e.stderr.decode()

# Iterate over scripts in the directory
for script_name in os.listdir(scripts_dir):
    script_path = os.path.join(scripts_dir, script_name)

    if not os.path.isfile(script_path):
        continue

    app_name = get_app_name(script_path)

    if app_name is None:
        print(f"No APP name found in {script_name}, skipping.")
        continue

    print(f"Processing {script_name} (APP={app_name})...")

    success, output = execute_script(script_path)

    if success:
        print(f"{app_name} succeeded.")
        with open(succeeded_file, 'a') as sf:
            sf.write(app_name + "\n")
    else:
        print(f"{app_name} failed: {output}")
        with open(fails_file, 'a') as ff:
            ff.write(app_name + "\n")

print("Processing complete.")
