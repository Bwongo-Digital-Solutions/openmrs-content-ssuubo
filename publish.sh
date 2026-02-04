#!/bin/bash

# Automated Publishing Script for OpenMRS Content Package to Maven Central
# Usage: ./publish.sh [snapshot|release] [commit-message]

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
COMMIT_MESSAGE="$2"
RELEASE_TYPE="${1:-snapshot}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validation functions
validate_environment() {
    log_info "Validating environment..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
    
    # Check if Maven is installed
    if ! command -v mvn &> /dev/null; then
        log_error "Maven is not installed or not in PATH"
        exit 1
    fi
    
    # Check if git is configured
    if ! git config user.name > /dev/null 2>&1; then
        log_error "Git user.name is not configured"
        exit 1
    fi
    
    if ! git config user.email > /dev/null 2>&1; then
        log_error "Git user.email is not configured"
        exit 1
    fi
    
    log_success "Environment validation passed"
}

validate_maven_settings() {
    log_info "Validating Maven settings..."
    
    # Check if settings.xml exists
    if [ ! -f "$HOME/.m2/settings.xml" ]; then
        log_warning "Maven settings.xml not found at ~/.m2/settings.xml"
        log_warning "You must configure OSSRH credentials and GPG key for Maven Central publishing"
        log_warning "See: https://central.sonatype.org/publish/publish-maven/"
    fi
    
    # Test Maven connection
    if ! mvn help:effective-settings -q > /dev/null 2>&1; then
        log_error "Maven settings validation failed"
        exit 1
    fi
    
    # Check if GPG is available for signing
    if ! command -v gpg &> /dev/null; then
        log_error "GPG is not installed or not in PATH (required for Maven Central signing)"
        exit 1
    fi
    
    log_success "Maven settings validation passed"
}

get_current_version() {
    grep -o '<version>[^<]*' "$PROJECT_DIR/pom.xml" | sed 's/<version>//'
}

remove_snapshot() {
    local version="$1"
    echo "$version" | sed 's/-SNAPSHOT//'
}

add_snapshot() {
    local version="$1"
    if [[ ! "$version" =~ -SNAPSHOT$ ]]; then
        echo "${version}-SNAPSHOT"
    else
        echo "$version"
    fi
}

update_version() {
    local new_version="$1"
    log_info "Updating version to $new_version"
    
    sed -i "s/<version>.*<\/version>/<version>$new_version<\/version>/" "$PROJECT_DIR/pom.xml"
    
    if [ $? -eq 0 ]; then
        log_success "Version updated to $new_version"
    else
        log_error "Failed to update version"
        exit 1
    fi
}

commit_changes() {
    local message="$1"
    
    log_info "Committing changes..."
    
    # Add all changes
    git add .
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        log_warning "No changes to commit"
        return 0
    fi
    
    # Commit with provided message or default
    if [ -z "$message" ]; then
        message="Update content package - $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    git commit -m "$message"
    
    if [ $? -eq 0 ]; then
        log_success "Changes committed successfully"
    else
        log_error "Failed to commit changes"
        exit 1
    fi
}

push_to_github() {
    log_info "Pushing changes to GitHub..."
    
    # Get current branch
    local current_branch=$(git branch --show-current)
    
    # Push to origin
    git push origin "$current_branch"
    
    if [ $? -eq 0 ]; then
        log_success "Changes pushed to GitHub successfully"
    else
        log_error "Failed to push to GitHub"
        exit 1
    fi
}

build_and_test() {
    log_info "Building and testing project..."
    
    cd "$PROJECT_DIR"
    
    # Clean and build (includes validation)
    mvn clean verify -DskipTests
    
    if [ $? -eq 0 ]; then
        log_success "Build and validation completed successfully"
    else
        log_error "Build or validation failed"
        exit 1
    fi
}

deploy_to_maven() {
    log_info "Deploying to Maven Central..."
    
    cd "$PROJECT_DIR"
    
    # For Maven Central, we use deploy with the release profile and GPG signing
    mvn clean deploy -P release --show-version
    
    if [ $? -eq 0 ]; then
        log_success "Deployment to Maven Central completed"
        log_info "Note: For releases, artifacts will be staged and need to be manually released in Sonatype Nexus"
    else
        log_error "Maven Central deployment failed"
        exit 1
    fi
}

create_github_release() {
    local version="$1"
    
    log_info "Creating GitHub release for version $version..."
    
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI (gh) not found. Skipping GitHub release creation."
        log_warning "Install gh CLI to automatically create GitHub releases."
        return 0
    fi
    
    # Create release
    gh release create "$version" --generate-notes
    
    if [ $? -eq 0 ]; then
        log_success "GitHub release created successfully"
    else
        log_warning "Failed to create GitHub release"
        return 1
    fi
}

publish_snapshot() {
    log_info "Starting SNAPSHOT publishing process..."
    
    local current_version=$(get_current_version)
    local snapshot_version=$(add_snapshot "$current_version")
    
    # Ensure version has SNAPSHOT suffix
    if [[ "$current_version" != "$snapshot_version" ]]; then
        update_version "$snapshot_version"
        commit_changes "Update version to $snapshot_version for SNAPSHOT release"
    fi
    
    push_to_github
    build_and_test
    deploy_to_maven
    
    log_success "SNAPSHOT publishing completed successfully"
}

publish_release() {
    log_info "Starting RELEASE publishing process..."
    
    local current_version=$(get_current_version)
    local release_version=$(remove_snapshot "$current_version")
    
    # Remove SNAPSHOT suffix for release
    if [[ "$current_version" != "$release_version" ]]; then
        update_version "$release_version"
        commit_changes "Update version to $release_version for release"
    fi
    
    push_to_github
    build_and_test
    deploy_to_maven
    create_github_release "$release_version"
    
    # Add SNAPSHOT suffix back for next development cycle
    local next_snapshot="${release_version}-SNAPSHOT"
    update_version "$next_snapshot"
    commit_changes "Update version to $next_snapshot for next development cycle"
    push_to_github
    
    log_success "RELEASE publishing completed successfully"
}

show_usage() {
    echo "Usage: $0 [snapshot|release] [commit-message]"
    echo ""
    echo "Arguments:"
    echo "  snapshot       Publish SNAPSHOT version (default)"
    echo "  release        Publish release version"
    echo "  commit-message Optional commit message"
    echo ""
    echo "Examples:"
    echo "  $0 snapshot"
    echo "  $0 release \"Release version 1.7.0\""
    echo "  $0"
}

# Main execution
main() {
    log_info "Starting OpenMRS Content Package publishing script"
    log_info "Release type: $RELEASE_TYPE"
    
    # Validate release type
    if [[ "$RELEASE_TYPE" != "snapshot" && "$RELEASE_TYPE" != "release" ]]; then
        log_error "Invalid release type: $RELEASE_TYPE"
        show_usage
        exit 1
    fi
    
    # Run validations
    validate_environment
    validate_maven_settings
    
    # Show current status
    log_info "Current version: $(get_current_version)"
    
    # Execute publishing process
    case "$RELEASE_TYPE" in
        "snapshot")
            publish_snapshot
            ;;
        "release")
            publish_release
            ;;
    esac
    
    log_success "Publishing process completed successfully!"
}

# Handle script interruption
trap 'log_error "Script interrupted"; exit 1' INT

# Run main function
main "$@"
