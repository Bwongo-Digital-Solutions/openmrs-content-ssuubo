# Automated Publishing Script for Maven Central

## Usage

```bash
# Snapshot publishing (default)
./publish.sh snapshot
./publish.sh

# Release publishing
./publish.sh release "Release version 1.7.0"

# With custom commit message
./publish.sh snapshot "Update locations configuration"
```

## Features

- **Environment validation** - Checks Git, Maven, and configuration
- **Version management** - Handles SNAPSHOT/release versions automatically  
- **Git operations** - Commits, pushes, and creates GitHub releases
- **Maven deployment** - Builds, tests, signs, and deploys to Maven Central
- **Error handling** - Comprehensive validation and error reporting

## Requirements

- Git configured with user.name and user.email
- Maven installed and configured
- GPG installed and configured for signing
- OSSRH (Sonatype) account and credentials in ~/.m2/settings.xml
- GitHub CLI (gh) for automatic release creation (optional)

## Script Actions

**Snapshot:**
1. Ensures version has -SNAPSHOT suffix
2. Commits and pushes changes
3. Builds and validates content package
4. Signs and deploys to Sonatype snapshots repository

**Release:**
1. Removes -SNAPSHOT suffix for release
2. Commits, pushes, builds, and deploys
3. Creates GitHub release
4. Adds -SNAPSHOT back for next development cycle
5. Artifacts are staged in Sonatype Nexus for manual release to Maven Central
