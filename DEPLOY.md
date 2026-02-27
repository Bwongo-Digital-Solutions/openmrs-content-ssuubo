# Local Deployment Script

## Quick Start

Deploy the current content package to a running OpenMRS distro:

```bash
./deploy-local.sh
```

## What It Does

1. **Builds** the content package using Maven
2. **Finds** running OpenMRS backend containers
3. **Extracts** configuration from the package
4. **Deploys** to the container's config directory
5. **Restarts** the container to reload configuration

## Requirements

- Maven installed
- Docker running
- At least one OpenMRS backend container running
- Content package and distro on the same machine

## Usage

### Single Container
If only one backend container is running, it deploys automatically:
```bash
./deploy-local.sh
```

### Multiple Containers
If multiple backend containers are running, you'll be prompted to select:
```bash
./deploy-local.sh
# Output:
# 1) openmrs-distro-ssuubo-emr-backend-1
# 2) openmrs-distro-test-backend-1
# Select container: 1
```

## What Gets Deployed

All configuration from the package:
- Forms (ampathforms)
- Concepts
- Metadata
- Address hierarchy
- Any other configuration files

## After Deployment

Wait ~2 minutes for OpenMRS to:
- Reload configuration
- Process new forms
- Update metadata

Check logs:
```bash
docker logs -f <container-name>
```

## Troubleshooting

**No containers found:**
- Ensure your OpenMRS distro is running
- Check: `docker ps | grep backend`

**Permission denied:**
- Make script executable: `chmod +x deploy-local.sh`

**Build fails:**
- Check Maven is installed: `mvn --version`
- Ensure all dependencies are available

**Container won't restart:**
- Check Docker daemon is running
- Verify container name is correct
