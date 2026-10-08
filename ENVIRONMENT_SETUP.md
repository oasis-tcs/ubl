# UBL Build Environment Setup

This document describes how to set up the required dependencies for building the UBL package with the shell build scripts.

## Required Dependencies

The following packages are required to run the full UBL build process:

1. **p7zip-full** (or 7zip) - For creating compressed archives
2. **aspell** - For spell checking documentation
3. **pandoc** - For document format conversion
4. **OpenJDK 8** - Java Development Kit version 8 (required, not optional)
5. **libreoffice** - For ODS to XLS conversion (optional, used when converting spreadsheets; see "The GitHub workflow" below for the fonts the XLS files depend on)

## Installation Instructions

### On Ubuntu/Debian Systems

```bash
# Update package lists
apt update

# Install all required packages
apt install -y p7zip-full aspell pandoc openjdk-8-jdk

# Optional: Install libreoffice if needed for spreadsheet conversion
apt install -y libreoffice
```

### Setting Java Version

If you have multiple Java versions installed, you need to set Java 8 as the default:

```bash
# List available Java versions
update-alternatives --list java

# Set Java 8 as default for java and javac
update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

# Verify Java version
java -version
# Should output: openjdk version "1.8.0_462"
```

## Verification

After installation, verify all tools are available:

```bash
# Verify 7z
7z --help

# Verify aspell
aspell --version

# Verify pandoc
pandoc --version

# Verify Java 8
java -version
```

## Running the Build

Once all dependencies are installed:

```bash
# Create target directory
mkdir target

# Run the build script
bash build.sh target github <label> "<username>" "<password>"

# Example without credentials (will skip documentation generation):
bash build.sh target github test-$(date +%Y%m%d) "" ""
```

## Known Issues and Limitations

### Google Sheets Download Requires Network Access

The build process attempts to download spreadsheet data from Google Sheets. This requires:
- Network access to docs.google.com
- Valid credentials (REALTA_USERNAME and REALTA_PASSWORD) if accessing restricted sheets
- No proxy blocking the requests

If the Google Sheets download fails with "403 Forbidden":
- The build will fail at the artefact generation stage
- Check network connectivity and proxy settings
- Ensure credentials are provided if required
- Or work with cached/local copies of the spreadsheets

### Build Exit Code Always Returns 0

The build scripts are configured to always return exit code 0 (`exit 0` at end of build-common.sh) to ensure GitHub Actions can retrieve the build artifacts even on failure. Check the actual build status in (with the version and stage set in `build.sh`):
- `target/UBL-<version>-<stage>-<label>-archive-only/build.exitcode.<label>.txt`
- `target/UBL-<version>-<stage>-<label>-archive-only/build.console.<label>.txt`

## Installation Success Confirmation

After following this setup, you should be able to:

✅ Run the build script without "command not found" errors
✅ See 7z compression working (output shows "7-Zip 23.01" and "Everything is Ok")
✅ Have Java 8 active (build output shows "Running on Java: 1.8.0_462")
✅ Generate .7z archive files in the target directory

Example successful output:
```
Building package...
Running on Java: 1.8.0_462 from /usr/lib/jvm/java-8-openjdk-amd64/jre
...
7-Zip 23.01 (x64) : Copyright (c) 1999-2023 Igor Pavlov : 2023-06-20
Creating archive: UBL-<version>-<stage>-<label>-archive-only.7z
Everything is Ok
```

## Environment Details (Last Tested)

- Platform: Ubuntu 24.04 (Noble)
- Java: OpenJDK 1.8.0_462
- 7-Zip: 23.01
- Aspell: 0.60.8.1
- Pandoc: 3.1.3

## The GitHub workflow

`.github/workflows/build.yml` installs, in its `Dependencies` step:

```yaml
sudo apt install -y aspell pandoc libreoffice-calc-nogui \
  fonts-crosextra-caladea fonts-crosextra-carlito fonts-liberation-sans-narrow \
  fonts-linuxlibertine fonts-noto-core fonts-noto-extra fonts-noto-mono \
  fonts-noto-ui-core fonts-opensymbol fonts-sil-gentium fonts-sil-gentium-basic
```

- LibreOffice is used only to convert the spreadsheets from ODS to XLS, so only its spreadsheet
  part is installed, without the rest of the office suite.
- The fonts are the ones the full `libreoffice` package brings. The column widths in the XLS files
  are worked out from font measurements, so with other fonts the XLS files come out differently.
  To get the same XLS files in a local build, install the same fonts.
- The jobs run on Ubuntu 24.04 (`ubuntu-24.04`), chosen on purpose: what the build installs comes
  with the Ubuntu version, so a newer one is a deliberate step, after comparing the packages built
  on both. 7-Zip comes with these build machines and is not installed separately.
- The step stops after 10 minutes: it normally takes under a minute, but when an Ubuntu package
  mirror stops answering, `apt` would otherwise wait without end.

The `Artwork tools` step installs what renders the figures from their drawings
(`utilities/artwork/README.md`). After the build, the `Timing summary` step puts a table of where
the build spent its time on the run's summary page.
