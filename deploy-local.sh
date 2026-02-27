#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== OpenMRS Content Package Local Deployment ===${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build package
echo -e "\n${YELLOW}[1/5] Building...${NC}"
mvn clean package -DskipTests

PACKAGE_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
PACKAGE_NAME=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)
PACKAGE_FILE="target/${PACKAGE_NAME}-${PACKAGE_VERSION}.zip"

[ ! -f "$PACKAGE_FILE" ] && echo -e "${RED}Package not found${NC}" && exit 1
echo -e "${GREEN}✓ Built: $PACKAGE_FILE${NC}"

# Find container
echo -e "\n${YELLOW}[2/5] Finding containers...${NC}"
CONTAINERS=$(docker ps --filter "name=backend" --filter "status=running" --format "{{.Names}}")
[ -z "$CONTAINERS" ] && echo -e "${RED}No containers found${NC}" && exit 1

CONTAINER_COUNT=$(echo "$CONTAINERS" | wc -l)
if [ $CONTAINER_COUNT -gt 1 ]; then
    echo "$CONTAINERS" | nl
    echo -e "${YELLOW}Select container:${NC}"
    select CONTAINER in $CONTAINERS; do [ -n "$CONTAINER" ] && break; done
else
    CONTAINER=$CONTAINERS
fi
echo -e "${GREEN}✓ Container: $CONTAINER${NC}"

# Extract
echo -e "\n${YELLOW}[3/5] Extracting...${NC}"
TEMP_DIR=$(mktemp -d)
unzip -q "$PACKAGE_FILE" -d "$TEMP_DIR"
CONFIG_DIR=$(find "$TEMP_DIR" -type d -name "configuration" | head -1)
[ -z "$CONFIG_DIR" ] && echo -e "${RED}No config found${NC}" && rm -rf "$TEMP_DIR" && exit 1

# Deploy
echo -e "\n${YELLOW}[4/5] Deploying...${NC}"
TARGET_PATH="/openmrs/distribution/openmrs_config"
docker cp "$CONFIG_DIR/." "$CONTAINER:$TARGET_PATH/"
echo -e "${GREEN}✓ Deployed${NC}"

# Restart
echo -e "\n${YELLOW}[5/5] Restarting...${NC}"
docker exec "$CONTAINER" sh -c "rm -rf /openmrs/data/configuration_checksums/* 2>/dev/null || true"
docker restart "$CONTAINER" > /dev/null

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✓ Deployment complete!${NC}"
echo -e "Container ${CONTAINER} is restarting..."
echo -e "Wait ~2 minutes for OpenMRS to reload the configuration."
