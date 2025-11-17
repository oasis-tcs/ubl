#!/usr/bin/env python3
"""
UBL Build Script - Python implementation matching shell script behavior.
Builds UBL packages and creates 7z archives.
"""

import os
import sys
import subprocess
import time
import shutil
import glob
from pathlib import Path
from dataclasses import dataclass
from typing import Optional


@dataclass
class BuildConfig:
    """Build configuration parameters."""
    target_dir: str
    platform: str
    label: str
    realta_username: str = ""
    realta_password: str = ""
    delete_option: str = ""

    # UBL configuration
    title: str = "UBL 2.5"
    package: str = "UBL-2.5"
    ubl_version: str = "2.5"
    ubl_stage: str = "csd02"
    ubl_prev_stage_version: str = "2.5"
    ubl_prev_stage: str = "csd01"
    ubl_prev_version: str = "2.4"
    raw_dir: str = "raw"
    is_draft: str = ""
    lib_google: str = "https://docs.google.com/spreadsheets/d/18o1YqjHWUw0-s8mb3ja4i99obOUhs-4zpgso6RZrGaY"
    doc_google: str = "https://docs.google.com/spreadsheets/d/1024Th-Uj8cqliNEJc-3pDOR7DxAAW7gCG4e-pbtarsg"
    sig_google: str = "https://docs.google.com/spreadsheets/d/1T6z2NZ4mc69YllZOXE5TnT5Ey-FlVtaXN1oQ4AIMp7g"


class BuildException(Exception):
    """Custom exception for build errors."""
    pass


def parse_arguments() -> BuildConfig:
    """Parse command line arguments into BuildConfig."""
    if len(sys.argv) < 4:
        raise BuildException(
            "Usage: build.py <target_dir> <platform> <label> [realta_username] [realta_password] [delete_option]"
        )

    return BuildConfig(
        target_dir=sys.argv[1],
        platform=sys.argv[2],
        label=sys.argv[3],
        realta_username=sys.argv[4] if len(sys.argv) > 4 else "",
        realta_password=sys.argv[5] if len(sys.argv) > 5 else "",
        delete_option=sys.argv[6] if len(sys.argv) > 6 else "",
    )


def create_directory_structure(config: BuildConfig) -> None:
    """Create necessary directory structure."""
    package_dir_name = f"{config.package}-{config.ubl_stage}-{config.label}"
    package_dir = Path(config.target_dir) / package_dir_name
    intermediate_dir = package_dir / "intermediate-support-files"
    
    intermediate_dir.mkdir(parents=True, exist_ok=True)


def build_ant_command(config: BuildConfig) -> list[str]:
    """Build the ANT command with all parameters."""
    target_dir_abs = os.path.abspath(config.target_dir)
    
    return [
        "java",
        f"-Dant.home=utilities/ant",
        "-classpath", "utilities/saxon/saxon.jar:utilities/ant/lib/ant-launcher.jar:utilities/saxon9he/saxon9he.jar",
        "org.apache.tools.ant.launch.Launcher",
        "-buildfile", "build-py.xml",
        f"-Dtitle={config.title}",
        f"-Dpackage={config.package}",
        f"-DUBLversion={config.ubl_version}",
        f"-DUBLprevStageVersion={config.ubl_prev_stage_version}",
        f"-DUBLprevStage={config.ubl_prev_stage}",
        f"-DUBLprevVersion={config.ubl_prev_version}",
        f"-Drawdir={config.raw_dir}",
        f"-DlibraryGoogle={config.lib_google}",
        f"-DdocumentsGoogle={config.doc_google}",
        f"-DsignatureGoogle={config.sig_google}",
        f"-Ddir={target_dir_abs}",
        f"-DUBLstage={config.ubl_stage}",
        f"-Dlabel={config.label}",
        f"-DisDraft={config.is_draft}",
        f"-Dplatform={config.platform}",
        f"-Drealtauser={config.realta_username}",
        f"-Drealtapass={config.realta_password}",
    ]


def run_ant_build(config: BuildConfig) -> int:
    """Run the ANT build process."""
    print("Building package...")
    result = subprocess.run(build_ant_command(config))
    
    # Sleep 2 seconds like the shell script
    time.sleep(2)
    
    return result.returncode


def move_logs_to_archive(config: BuildConfig, archive_dir: Path) -> None:
    """Move build logs to archive directory."""
    # Move console log
    console_log = Path(f"build.console.{config.label}.txt")
    if console_log.exists():
        console_log.rename(archive_dir / console_log.name)
    
    # Move Saxon log files
    for log_file in glob.glob("saxon*.log"):
        Path(log_file).rename(archive_dir / Path(log_file).name)


def write_exit_code(config: BuildConfig, archive_dir: Path, exit_code: int) -> None:
    """Write build exit code to file."""
    exit_code_file = archive_dir / f"build.exitcode.{config.label}.txt"
    exit_code_file.write_text(f"{exit_code}\n")


def ensure_console_log_exists(config: BuildConfig, archive_dir: Path) -> None:
    """Ensure console log file exists (touch equivalent)."""
    console_log = archive_dir / f"build.console.{config.label}.txt"
    console_log.touch()


def create_7z_archive(archive_path: Path, source_dir: Path) -> None:
    """Create a 7z archive from a source directory using system 7z command."""
    print(f"Creating {archive_path.name}...")
    work_dir = source_dir.parent  # /home/runner/work/ubl/ubl/target
    source_dir_relative = source_dir.name  # e.g., 'UBL-2.5-csd01-20251020-0832z'
    archive_path_relative = archive_path.name  # e.g., 'UBL-2.5-csd01-20251020-0832z.7z'
    subprocess.run([
        "7z", "a", "-t7z", "-mx=9", "-mfb=128", "-md=64m", "-mqs=on", "-aoa",
        archive_path_relative,
        source_dir_relative,
    ], cwd=work_dir, check=False)


def archive_build_outputs(config: BuildConfig, exit_code: int) -> None:
    """Create 7z archives for build outputs."""
    base_dir = Path(config.target_dir)
    
    # Define directory structure
    archive_dir_name = f"{config.package}-{config.ubl_stage}-{config.label}-archive-only"
    iso_dir_name = f"{config.package}-{config.ubl_stage}-{config.label}-iso-iec-19845"
    package_dir_name = f"{config.package}-{config.ubl_stage}-{config.label}"
    
    archive_dir = base_dir / archive_dir_name
    iso_dir = base_dir / iso_dir_name
    package_dir = base_dir / package_dir_name
    
    # Prepare archive directory
    archive_dir.mkdir(parents=True, exist_ok=True)
    move_logs_to_archive(config, archive_dir)
    write_exit_code(config, archive_dir, exit_code)
    ensure_console_log_exists(config, archive_dir)
    
    # Define zip file paths
    archive_zip = base_dir / f"{archive_dir_name}.7z"
    iso_zip = base_dir / f"{iso_dir_name}.7z"
    main_zip = base_dir / f"{package_dir_name}.7z"
    
    # Remove existing archives
    for zip_file in [archive_zip, iso_zip, main_zip]:
        zip_file.unlink(missing_ok=True)
    
    # Create archives
    create_7z_archive(archive_zip, archive_dir)
    create_7z_archive(iso_zip, iso_dir)
    create_7z_archive(main_zip, package_dir)


def cleanup_github(config: BuildConfig) -> None:
    """Clean up files for GitHub Actions to reduce storage costs."""
    if config.target_dir != "target" or config.platform != "github" or config.delete_option != "DELETE-REPOSITORY-FILES-AS-WELL":
        return
    
    print("Cleaning up repository files...")
    # Delete everything in root except target and .github directories
    for item in Path(".").iterdir():
        if item.name not in ("target", ".github"):
            if item.is_dir():
                shutil.rmtree(item, ignore_errors=True)
            elif item.is_file():
                item.unlink(missing_ok=True)
    
    # Move zip files to root
    print("Moving zip files to root...")
    target_path = Path(config.target_dir)
    for zip_file in target_path.glob("*.7z"):
        zip_file.rename(Path(zip_file.name))
    
    # Remove target directory
    print(f"Removing {config.target_dir} directory...")
    shutil.rmtree(config.target_dir, ignore_errors=True)


def main() -> int:
    """Main build process."""
    try:
        config = parse_arguments()
        
        print(f"Building with label: {config.label}")
        print(f"Platform: {config.platform}")
        
        create_directory_structure(config)
        exit_code = run_ant_build(config)
        archive_build_outputs(config, exit_code)
        cleanup_github(config)
        
        return 0  # Always exit successfully like shell script
        
    except BuildException as e:
        print(f"Build error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())