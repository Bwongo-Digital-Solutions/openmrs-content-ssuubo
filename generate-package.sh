#!/bin/bash

# SSUUBO Content Package Generator Script
# Usage: ./generate-package.sh [version]

set -e

echo "🚀 Starting SSUUBO Content Package Generation..."

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed or not in PATH"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 11 ]; then
    echo "⚠️  Warning: Java 11+ recommended, found Java $JAVA_VERSION"
fi

# Update version if provided
if [ ! -z "$1" ]; then
    echo "📦 Updating version to: $1"
    mvn versions:set -DnewVersion="$1"
    mvn versions:commit
fi

# Get current project info
GROUP_ID=$(mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout)
ARTIFACT_ID=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)
VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

echo "📋 Project Info:"
echo "   Group ID: $GROUP_ID"
echo "   Artifact ID: $ARTIFACT_ID"
echo "   Version: $VERSION"

# Clean and validate
echo "🧹 Cleaning previous builds..."
mvn clean

echo "✅ Validating content package..."
mvn verify -DskipTests

# Build the package (verify already included validation)
echo "🔨 Building package..."
mvn package -DskipTests

# Check if package was created
PACKAGE_FILE="target/${ARTIFACT_ID}-${VERSION}.zip"
if [ -f "$PACKAGE_FILE" ]; then
    echo "✅ Package generated successfully: $PACKAGE_FILE"
    
    # Show package info
    echo "📊 Package Information:"
    ls -lh "$PACKAGE_FILE"
    echo ""
    echo "📦 Package contents:"
    if command -v unzip &> /dev/null; then
        unzip -l "$PACKAGE_FILE" | head -20
        if [ $(unzip -l "$PACKAGE_FILE" | wc -l) -gt 20 ]; then
            echo "... and more files"
        fi
        
        # Test package integrity
        echo "🔍 Testing package integrity..."
        unzip -t "$PACKAGE_FILE"
    else
        echo "   Install 'unzip' to view package contents and test integrity"
        echo "   Package file: $PACKAGE_FILE"
    fi
    
    echo ""
    echo "🎉 Package generation completed!"
    echo "📍 Location: $PACKAGE_FILE"
    echo ""
    echo "📋 To use this package:"
    echo "   1. Deploy to GitHub: git tag v$VERSION && git push origin v$VERSION"
    echo "   2. Or manually upload to your Maven repository"
    echo "   3. Add dependency to your distro:"
    echo "      <dependency>"
    echo "        <groupId>$GROUP_ID</groupId>"
    echo "        <artifactId>$ARTIFACT_ID</artifactId>"
    echo "        <version>$VERSION</version>"
    echo "        <type>zip</type>"
    echo "      </dependency>"
    
else
    echo "❌ Package generation failed!"
    echo "Check the Maven output above for errors"
    exit 1
fi
