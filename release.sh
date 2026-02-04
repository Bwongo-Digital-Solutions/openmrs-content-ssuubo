#!/bin/bash

# Automated Release Script for SSUUBO Content Package
# This script automates the Maven release process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pom.xml" ]; then
    print_error "pom.xml not found. Please run this script from the project root."
    exit 1
fi

# Check if git is clean
if [ -n "$(git status --porcelain)" ]; then
    print_error "Working directory is not clean. Please commit or stash changes first."
    git status --porcelain
    exit 1
fi

print_status "Starting automated release process for SSUUBO Content Package"

# Get current version
CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
print_status "Current version: $CURRENT_VERSION"

# Check if current version is SNAPSHOT
if [[ ! $CURRENT_VERSION == *"-SNAPSHOT" ]]; then
    print_error "Current version is not a SNAPSHOT version. Cannot release."
    exit 1
fi

# Extract version number without SNAPSHOT
VERSION_NUMBER=${CURRENT_VERSION%"-SNAPSHOT"}

print_status "Will release version: $VERSION_NUMBER"

# Confirm release
read -p "Do you want to proceed with releasing version $VERSION_NUMBER? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Release cancelled by user."
    exit 0
fi

print_status "Starting Maven release process..."

# Step 1: Release prepare
print_status "Step 1: Preparing release..."
if mvn release:prepare; then
    print_success "Release preparation completed successfully"
else
    print_error "Release preparation failed"
    exit 1
fi

# Step 2: Release perform
print_status "Step 2: Performing release and deploying to Maven Central..."
if mvn release:perform; then
    print_success "Release performed successfully"
else
    print_error "Release performance failed"
    exit 1
fi

# Verify tag was created
if git rev-parse "refs/tags/$VERSION_NUMBER" > /dev/null 2>&1; then
    print_success "Git tag $VERSION_NUMBER created successfully"
else
    print_error "Git tag $VERSION_NUMBER was not created"
    exit 1
fi

# Show final status
print_success "Release $VERSION_NUMBER completed successfully!"
echo
print_status "Release Summary:"
echo "  - Version: $VERSION_NUMBER"
echo "  - Git Tag: $VERSION_NUMBER"
echo "  - Maven Central: Published (may take some time to sync)"
echo "  - Next Development Version: $(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)"
echo
print_status "You can now:"
echo "  1. Check the release at: https://central.sonatype.com"
echo "  2. Update your distribution to use version $VERSION_NUMBER"
echo "  3. Continue development with the new SNAPSHOT version"

# Optional: Push to remote
read -p "Do you want to push the release tag to remote repository? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Pushing release tag to remote..."
    git push origin "refs/tags/$VERSION_NUMBER"
    print_success "Release tag pushed to remote"
fi

print_success "Automated release process completed!"
