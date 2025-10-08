#!/usr/bin/env python3
import os
import sys
import subprocess
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
    os.environ["JAVA_HOME"] = "/usr/lib/jvm/java-8-openjdk-amd64"
    os.environ["ANT_HOME"] = "/usr/share/ant"
    os.environ["PATH"] = f"{os.environ['ANT_HOME']}/bin:{os.environ['PATH']}"

def create_directories(target_dir, package, UBLstage, label):
    """Create necessary directories."""
    package_dir = f"{target_dir}/{package}-{UBLstage}-{label}"
    intermediate_dir = f"{package_dir}/intermediate-support-files"
    archive_dir = f"{target_dir}/{package}-{UBLstage}-{label}-archive-only"

    Path(package_dir).mkdir(parents=True, exist_ok=True)
    Path(intermediate_dir).mkdir(parents=True, exist_ok=True)
    Path(archive_dir).mkdir(parents=True, exist_ok=True)

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
        f"-DUBLstage={os.environ.get('UBLstage', '')}",
        f"-Dlabel={label}",
        f"-Dplatform={platform}",
        f"-Drealtauser={realta_username}",
        f"-Drealtapass={realta_password}"
    ]

    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running ANT script: {e}")
        sys.exit(1)

def archive_and_cleanup(target_dir, package, UBLstage, label, platform, delete_option):
    """Archive files and clean up."""
    archive_dir = f"{target_dir}/{package}-{UBLstage}-{label}-archive-only"
    os.rename(f"build.console.{label}.txt", f"{archive_dir}/build.console.{label}.txt")

    # Zip directories
    subprocess.run(f"7z a -t7z -mx=9 -mfb=128 -md=64m -mqs=on -aoa {package}-{UBLstage}-{label}-archive-only.zip {package}-{UBLstage}-{label}-archive-only", shell=True)
    subprocess.run(f"7z a -t7z -mx=9 -mfb=128 -md=64m -mqs=on -aoa {package}-{UBLstage}-{label}-iso-iec-19845.zip {package}-{UBLstage}-{label}-iso-iec-19845", shell=True)
    subprocess.run(f"7z a -t7z -mx=9 -mfb=128 -md=64m -mqs=on -aoa {package}-{UBLstage}-{label}.zip {package}-{UBLstage}-{label}", shell=True)

    if target_dir == "target" and platform == "github" and delete_option == "DELETE-REPOSITORY-FILES-AS-WELL":
        subprocess.run("find . -not -name target -not -name .github -maxdepth 1 -exec rm -r -f {} \\;", shell=True)
        subprocess.run(f"mv {target_dir}/{package}-{UBLstage}-{label}-archive-only.zip .", shell=True)
        subprocess.run(f"mv {target_dir}/{package}-{UBLstage}-{label}-iso-iec-19845.zip .", shell=True)
        subprocess.run(f"mv {target_dir}/{package}-{UBLstage}-{label}.zip .", shell=True)
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
    os.environ["libGoogle"] = "https://docs.google.com/spreadsheets/d/18o1YqjHWUw0-s8mb3ja4i99obOUhs-4zpgso6RZrGaY"
    os.environ["docGoogle"] = "https://docs.google.com/spreadsheets/d/1024Th-Uj8cqliNEJc-3pDOR7DxAAW7gCG4e-pbtarsg"
    os.environ["sigGoogle"] = "https://docs.google.com/spreadsheets/d/1T6z2NZ4mc69YllZOXE5TnT5Ey-FlVtaXN1oQ4AIMp7g"

    setup_environment()
    create_directories(target_dir, os.environ["package"], os.environ["UBLstage"], label)
    run_ant_script(target_dir, platform, label, realta_username, realta_password)
    archive_and_cleanup(target_dir, os.environ["package"], os.environ["UBLstage"], label, platform, delete_option)

if __name__ == "__main__":
    main()
