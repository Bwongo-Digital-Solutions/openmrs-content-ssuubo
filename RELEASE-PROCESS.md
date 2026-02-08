# Enhanced Release Process for SSUUBO Content Package

## Overview
This document describes the enhanced release process implemented in version 1.0.10+ that includes comprehensive validation and verification steps.

## Prerequisites
- Clean working directory (all changes committed)
- Maven installed and configured
- GPG keys configured for signing
- Network connectivity to Maven Central

## Release Steps

### 1. Pre-Release Validation
The enhanced script automatically performs these checks:

#### Package Structure Validation
- Verifies `frontend` directory is included in `assembly.xml`
- Ensures all frontend files will be packaged

#### Registration Configuration Validation
- Checks `registration.json` uses `conceptUuid` instead of concept names
- Validates JSON syntax using Python json.tool
- Prevents deployment failures due to configuration errors

#### SCD Concepts Verification
- Confirms `scd-concepts-core.csv` exists
- Verifies `scd-answers-core.csv` exists
- Ensures all required concepts are available

#### Network Connectivity Check
- Tests connectivity to Maven Central servers
- Warns if deployment might fail due to network issues

### 2. Maven Release Execution
```bash
# Prepare release (creates tag, updates versions)
mvn release:prepare -DautoVersionSubmodules=true -DpushChanges=false -DskipTests=true

# Perform release (builds and deploys)
mvn release:perform -DskipTests=true
```

### 3. Post-Release Verification
- Verifies tag creation
- Confirms next version is set
- Provides release summary

## Usage

### Quick Release (Recommended)
```bash
./quick-release.sh
```

### Manual Release Steps
If you need to perform steps manually:

1. **Validate Configuration**
   ```bash
   python3 -m json.tool configuration/frontend_configuration/registration.json
   grep -q "frontend" assembly.xml
   ```

2. **Prepare Release**
   ```bash
   mvn release:prepare -DautoVersionSubmodules=true -DpushChanges=false -DskipTests=true
   ```

3. **Perform Release**
   ```bash
   mvn release:perform -DskipTests=true
   ```

4. **Verify Tag**
   ```bash
   git tag | grep <version>
   ```

## Troubleshooting

### Network Issues
If you encounter "Broken pipe" errors:
1. Wait for network stability
2. Retry deployment later
3. Check Maven Central status

### Configuration Errors
If validation fails:
1. Check JSON syntax: `python3 -m json.tool configuration/frontend_configuration/registration.json`
2. Verify concept UUIDs are used instead of names
3. Ensure all concept files exist

### Missing Concepts
If SCD concepts are missing:
1. Verify `scd-concepts-core.csv` exists
2. Verify `scd-answers-core.csv` exists
3. Check concept UUID references in registration.json

## Release History

### Version 1.0.9
- Fixed registration app configuration
- Added SCD-specific concepts
- Updated assembly.xml to include frontend files
- Network connectivity issues prevented final deployment

### Version 1.0.10+
- Enhanced release script with comprehensive validation
- Automated pre-release checks
- Improved error handling and reporting
- Network connectivity verification

## Next Steps

For each new release:
1. Update version in `pom.xml` to `<next-version>-SNAPSHOT`
2. Commit changes
3. Run `./quick-release.sh`
4. Verify deployment on Maven Central

## Maven Central Verification

After successful release:
1. Visit https://central.sonatype.com/
2. Search for `io.github.tendomart:ssuubo`
3. Verify version appears in search results
4. Check that all artifacts are available

## Support

For issues with the release process:
1. Check this document for troubleshooting steps
2. Review script output for specific error messages
3. Verify all prerequisites are met
4. Check network connectivity to Maven Central
