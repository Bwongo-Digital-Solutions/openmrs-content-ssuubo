# Release Automation Scripts

This directory contains automated release scripts for the SSUUBO Content Package.

## Scripts

### `release.sh` (Interactive Release)
Full-featured release script with safety checks and user confirmation.

**Features:**
- Validates working directory is clean
- Checks current version is SNAPSHOT
- Interactive confirmation prompts
- Colored output and detailed logging
- Optional remote tag push
- Comprehensive error handling

**Usage:**
```bash
./release.sh
```

### `quick-release.sh` (Fast Release)
Simplified script for quick releases without prompts.

**Features:**
- Fast execution without user interaction
- Basic validation checks
- Minimal output
- Automatic version increment

**Usage:**
```bash
./quick-release.sh
```

## Prerequisites

1. **Clean working directory**: All changes must be committed
2. **SNAPSHOT version**: Current version must end with `-SNAPSHOT`
3. **GPG keys**: Configured for artifact signing
4. **Maven settings**: Proper credentials for Maven Central

## Release Process

Both scripts perform these steps:
1. `mvn release:prepare` - Updates version, creates tag
2. `mvn release:perform` - Builds and deploys to Maven Central
3. Verification of tag creation
4. Updates to next development version

## Post-Release

After release:
- Check Maven Central: https://central.sonatype.com
- Update distribution configurations to use new version
- Continue development with new SNAPSHOT version

## Troubleshooting

**Common Issues:**
- **Dirty working directory**: Commit or stash changes first
- **Non-SNAPSHOT version**: Update pom.xml to `-SNAPSHOT` version
- **GPG errors**: Ensure GPG keys are properly configured
- **Network issues**: Check internet connection and Maven repositories

**Manual Recovery:**
If release fails, you may need to:
1. Clean up failed release: `mvn release:clean`
2. Reset git state: `git reset --hard HEAD`
3. Check and fix the issue, then retry
