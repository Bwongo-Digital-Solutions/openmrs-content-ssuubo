#!/bin/bash

# Enhanced Release Script for SSUUBO Content Package
# Includes all pre-release validation and post-release verification steps
# Updated for version 1.0.10 and beyond

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

# Check prerequisites
if [ ! -f "pom.xml" ]; then
    print_error "pom.xml not found. Run from project root."
    exit 1
fi

print_status "Starting enhanced release process..."

# Step 1: Check working directory status
if [ -n "$(git status --porcelain)" ]; then
    print_error "Working directory not clean. Commit changes first."
    git status --short
    exit 1
fi
print_success "Working directory is clean"

# Step 2: Validate package structure
print_status "Validating package structure..."

# Check if frontend files are included in assembly
if ! grep -q "frontend" assembly.xml; then
    print_warning "Frontend directory not included in assembly.xml"
    print_status "Adding frontend files to assembly configuration..."
    # Add frontend fileset to assembly.xml
    sed -i '/<\/fileSets>/i\
\		<fileSet>\
\			<directory>${project.basedir}/frontend</directory>\
\			<includes>\
\				<include>**/*</include>\
\			</includes>\
\		</fileSet>' assembly.xml
fi

# Step 3: Validate registration configuration
print_status "Validating registration configuration..."

# Check if registration.json uses conceptUuid instead of concept names
if [ -f "configuration/frontend_configuration/registration.json" ]; then
    if grep -q '"concept":' configuration/frontend_configuration/registration.json; then
        print_warning "Registration config still uses concept names instead of UUIDs"
        print_status "This may cause issues during deployment"
    else
        print_success "Registration configuration uses proper UUIDs"
    fi
    
    # Validate JSON syntax
    if python3 -m json.tool configuration/frontend_configuration/registration.json > /dev/null 2>&1; then
        print_success "Registration JSON syntax is valid"
    else
        print_error "Registration JSON has syntax errors"
        exit 1
    fi
fi

# Step 4: Check for SCD concepts
print_status "Checking for SCD-specific concepts..."

if [ -f "configuration/backend_configuration/concepts/scd-concepts-core.csv" ] && 
   [ -f "configuration/backend_configuration/concepts/scd-answers-core.csv" ]; then
    print_success "SCD concepts files found"
else
    print_warning "SCD concept files missing - registration may fail"
fi

# Step 5: Get current version and prepare release
CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
VERSION_NUMBER=${CURRENT_VERSION%"-SNAPSHOT"}

print_status "Releasing version: $VERSION_NUMBER"

# Step 6: Execute Maven release
print_status "Executing Maven release prepare..."
mvn release:prepare -DautoVersionSubmodules=true -DpushChanges=false -DskipTests=true

print_status "Executing Maven release perform..."
mvn release:perform -DskipTests=true

# Step 7: Verify release completion
if git rev-parse "refs/tags/$VERSION_NUMBER" > /dev/null 2>&1; then
    print_success "Release $VERSION_NUMBER completed!"
    echo "Tag: $VERSION_NUMBER"
    
    # Step 8: Post-release verification
    print_status "Performing post-release verification..."
    
    # Check if tag was created
    if git tag | grep -q "$VERSION_NUMBER"; then
        print_success "Tag $VERSION_NUMBER created successfully"
    else
        print_error "Tag creation failed"
        exit 1
    fi
    
    # Get next version
    NEXT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    echo "Next version: $NEXT_VERSION"
    
    # Step 9: Network connectivity check for Maven Central
    print_status "Checking Maven Central connectivity..."
    if curl -s --connect-timeout 10 https://s01.oss.sonatype.org/ > /dev/null; then
        print_success "Maven Central is reachable"
    else
        print_warning "Maven Central may be unreachable - deployment might fail"
        print_status "If deployment fails, retry later when network is stable"
    fi
    
    print_success "Release process completed successfully!"
    print_status "Summary of changes included in this release:"
    echo "  - Frontend files packaging fix"
    echo "  - Registration app configuration with conceptUuids"
    echo "  - SCD-specific concepts and answers"
    echo "  - JSON syntax validation"
    echo "  - Enhanced pre-release validation"
    
else
    print_error "Release failed - tag not found"
    exit 1
fi
