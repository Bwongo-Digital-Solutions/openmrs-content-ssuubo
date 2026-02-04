#!/bin/bash

# Quick Release Script for SSUUBO Content Package
# Simplified version for fast releases without prompts

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check prerequisites
if [ ! -f "pom.xml" ]; then
    echo "ERROR: pom.xml not found. Run from project root."
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "ERROR: Working directory not clean. Commit changes first."
    exit 1
fi

print_status "Starting quick release..."

# Get current version
CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
VERSION_NUMBER=${CURRENT_VERSION%"-SNAPSHOT"}

print_status "Releasing version: $VERSION_NUMBER"

# Execute release
mvn release:prepare -DautoVersionSubmodules=true -DpushChanges=false
mvn release:perform

# Verify and show results
if git rev-parse "refs/tags/$VERSION_NUMBER" > /dev/null 2>&1; then
    print_success "Release $VERSION_NUMBER completed!"
    echo "Tag: $VERSION_NUMBER"
    echo "Next version: $(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)"
else
    echo "ERROR: Release failed - tag not found"
    exit 1
fi
