#!/usr/bin/env python3
import os
import sys
import subprocess
import time
import glob
from pathlib import Path

def parse_arguments():
    """Parse command line arguments."""
    if len(sys.argv) < 4:
        print("Usage: build.py <target_dir> <platform> <label> [realta_username] [realta_password] [delete_option]")
        sys.exit(1)

    target_dir = sys.argv[1]
    platform = sys.argv[2]
    label = sys.argv[3]
    realta_username = sys.argv[4] if len(sys.argv) > 4 else ""
    realta_password = sys.argv[5] if len(sys.argv) > 5 else ""
    delete_option = sys.argv[6] if len(sys.argv) > 6 else ""

    return target_dir, platform, label, realta_username, realta_password, delete_option

def setup_environment():
    """Set up environment variables and paths."""
    # os.environ["JAVA_HOME"] = "/usr/lib/jvm/java-8-openjdk-amd64"
    # os.environ["ANT_HOME"] = "/usr/share/ant"
    # os.environ["PATH"] = f"{os.environ['ANT_HOME']}/bin:{os.environ['PATH']}"

def create_directories(target_dir, package, UBLstage, label):
    """Create necessary directories."""
    package_dir = f"{target_dir}/{package}-{UBLstage}-{label}"
    intermediate_dir = f"{package_dir}/intermediate-support-files"
    archive_dir = f"{target_dir}/{package}-{UBLstage}-{label}-archive-only"

    Path(package_dir).mkdir(parents=True, exist_ok=True)
    Path(intermediate_dir).mkdir(parents=True, exist_ok=True)
    Path(archive_dir).mkdir(parents=True, exist_ok=True)

    targetdirabs = os.path.abspath(target_dir)
    os.environ["targetdirabs"] = targetdirabs

def run_ant_script(target_dir, platform, label, realta_username, realta_password):
    """Run the ANT script."""
    command = [
        "java",
        f"-Dant.home=utilities/ant",
        "-classpath", "utilities/saxon/saxon.jar:utilities/ant/lib/ant-launcher.jar:utilities/saxon9he/saxon9he.jar",
        "org.apache.tools.ant.launch.Launcher",
        "-buildfile", "build.xml",
        f"-Dtitle={os.environ.get('title', '')}",
        f"-Dpackage={os.environ.get('package', '')}",
        f"-DUBLversion={os.environ.get('UBLversion', '')}",
        f"-DUBLprevStageVersion={os.environ.get('UBLprevStageVersion', '')}",
        f"-DUBLprevStage={os.environ.get('UBLprevStage', '')}",
        f"-DUBLprevVersion={os.environ.get('UBLprevVersion', '')}",
        f"-Drawdir={os.environ.get('rawdir', '')}",
        f"-DlibraryGoogle={os.environ.get('libGoogle', '')}",
        f"-DdocumentsGoogle={os.environ.get('docGoogle', '')}",
        f"-DsignatureGoogle={os.environ.get('sigGoogle', '')}",
        f"-Ddir={os.environ.get('targetdirabs', '')}",
        f"-DUBLstage={os.environ.get('UBLstage', '')}",
        f"-Dlabel={label}",
        f"-DisDraft={os.environ.get('isDraft', '')}",
        f"-Dplatform={platform}",
        f"-Drealtauser={realta_username}",
        f"-Drealtapass={realta_password}"
    ]

    print("Building package...")
    result = subprocess.run(command)
    server_return = result.returncode
    
    # Sleep 2 seconds like the shell script
    time.sleep(2)
    
    return server_return

def archive_and_cleanup(target_dir, package, UBLstage, label, platform, delete_option, server_return):
    """Archive files and clean up."""
    archive_dir = f"{target_dir}/{package}-{UBLstage}-{label}-archive-only"
    
    # Create archive directory if it doesn't exist
    Path(archive_dir).mkdir(parents=True, exist_ok=True)
    
    # Move build console log
    console_log = f"build.console.{label}.txt"
    if os.path.exists(console_log):
        os.rename(console_log, f"{archive_dir}/{console_log}")
    
    # Move Saxon log files if they exist
    saxon_logs = glob.glob("saxon*.log")
    for log_file in saxon_logs:
        os.rename(log_file, f"{archive_dir}/{log_file}")
    
    # Write exit code
    with open(f"{archive_dir}/build.exitcode.{label}.txt", 'w') as f:
        f.write(str(server_return) + '\n')
    
    # Touch the console log file to ensure it exists
    Path(f"{archive_dir}/build.console.{label}.txt").touch()
    
    # Change to target directory for zipping
    original_dir = os.getcwd()
    os.chdir(target_dir)
    
    try:
        # Remove existing zip files if they exist
        archive_zip = f"{package}-{UBLstage}-{label}-archive-only.7z"
        iso_zip = f"{package}-{UBLstage}-{label}-iso-iec-19845.7z"
        main_zip = f"{package}-{UBLstage}-{label}.7z"
        
        if os.path.exists(archive_zip):
            os.remove(archive_zip)
        if os.path.exists(iso_zip):
            os.remove(iso_zip)
        if os.path.exists(main_zip):
            os.remove(main_zip)
        
        # Zip directories
        subprocess.run([
            "7z", "a", "-t7z", "-mx=9", "-mfb=128", "-md=64m", "-mqs=on", "-aoa",
            archive_zip,
            archive_dir
        ])
        
        subprocess.run([
            "7z", "a", "-t7z", "-mx=9", "-mfb=128", "-md=64m", "-mqs=on", "-aoa",
            iso_zip,
            iso_dir
        ])
        
        subprocess.run([
            "7z", "a", "-t7z", "-mx=9", "-mfb=128", "-md=64m", "-mqs=on", "-aoa",
            main_zip,
            package_dir
        ])
    finally:
        # Return to original directory
        os.chdir(original_dir)
    
    # Conditional cleanup for GitHub
    if target_dir == "target-py" and platform == "github" and delete_option == "DELETE-REPOSITORY-FILES-AS-WELL":
        # Delete repository files except target and .github
        subprocess.run(
            "find . -not -name target-py -not -name .github -maxdepth 1 -exec rm -r -f {} \\;",
            shell=True
        )
        
        # Move zip files to root
        subprocess.run(f"mv {target_dir}/{package}-{UBLstage}-{label}-archive-only.7z .", shell=True)
        subprocess.run(f"mv {target_dir}/{package}-{UBLstage}-{label}-iso-iec-19845.7z .", shell=True)
        subprocess.run(f"mv {target_dir}/{package}-{UBLstage}-{label}.7z .", shell=True)
        
        # Remove target directory
        subprocess.run(f"rm -r -f {target_dir}", shell=True)

def main():
    target_dir, platform, label, realta_username, realta_password, delete_option = parse_arguments()

    # Set environment variables
    os.environ["title"] = "UBL 2.5"
    os.environ["package"] = "UBL-2.5"
    os.environ["UBLversion"] = "2.5"
    os.environ["UBLstage"] = "csd01"
    os.environ["UBLprevStageVersion"] = "2.4"
    os.environ["UBLprevStage"] = "os"
    os.environ["UBLprevVersion"] = "2.4"
    os.environ["rawdir"] = "raw"
    os.environ["isDraft"] = os.environ.get("isDraft", "")  # Use existing or empty
    os.environ["libGoogle"] = "https://docs.google.com/spreadsheets/d/18o1YqjHWUw0-s8mb3ja4i99obOUhs-4zpgso6RZrGaY"
    os.environ["docGoogle"] = "https://docs.google.com/spreadsheets/d/1024Th-Uj8cqliNEJc-3pDOR7DxAAW7gCG4e-pbtarsg"
    os.environ["sigGoogle"] = "https://docs.google.com/spreadsheets/d/1T6z2NZ4mc69YllZOXE5TnT5Ey-FlVtaXN1oQ4AIMp7g"

    setup_environment()
    create_directories(target_dir, os.environ["package"], os.environ["UBLstage"], label)
    server_return = run_ant_script(target_dir, platform, label, realta_username, realta_password)
    archive_and_cleanup(target_dir, os.environ["package"], os.environ["UBLstage"], label, platform, delete_option, server_return)
    
    # Always exit successfully like the shell script
    sys.exit(0)

if __name__ == "__main__":
    main()
