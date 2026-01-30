# Using SSUUBO Content Package in Custom OpenMRS Distribution

## Overview

Your content package artifact (`referenceapplication-demo-1.7.0-SNAPSHOT.zip`) contains:
- **Backend configuration** - Locations, concepts, forms, etc.
- **Frontend configuration** - SPA modules and UI settings
- **Metadata** - Content package dependencies and version info

## Method 1: Maven Dependency (Recommended)

### 1. Add Repository to Your Distro's `pom.xml`

```xml
<repositories>
    <repository>
        <id>openmrs-repo</id>
        <name>OpenMRS Public Repository</name>
        <url>https://mavenrepo.openmrs.org/public</url>
    </repository>
    <repository>
        <id>openmrs-snapshots</id>
        <name>OpenMRS Snapshot Repository</name>
        <url>https://mavenrepo.openmrs.org/snapshots</url>
    </repository>
</repositories>
```

### 2. Add Content Package Dependency

```xml
<dependencies>
    <!-- SSUUBO Content Package -->
    <dependency>
        <groupId>org.openmrs.content</groupId>
        <artifactId>referenceapplication-demo</artifactId>
        <version>1.7.0-SNAPSHOT</version>
        <type>zip</type>
        <scope>runtime</scope>
    </dependency>
</dependencies>
```

### 3. Configure OpenMRS to Load Content

Add to your distro's `configuration/openmrs.xml`:

```xml
<property>
    <name>content.packages</name>
    <value>referenceapplication-demo-1.7.0-SNAPSHOT</value>
</property>
```

## Method 2: Manual Deployment

### 1. Download the Artifact

```bash
# From Maven repository
wget https://mavenrepo.openmrs.org/snapshots/org/openmrs/content/referenceapplication-demo/1.7.0-SNAPSHOT/referenceapplication-demo-1.7.0-SNAPSHOT.zip

# Or from your local build
cp target/referenceapplication-demo-1.7.0-SNAPSHOT.zip /path/to/openmrs/
```

### 2. Deploy to OpenMRS

```bash
# Copy to OpenMRS content directory
cp referenceapplication-demo-1.7.0-SNAPSHOT.zip /path/to/openmrs/content/

# Extract if needed
unzip referenceapplication-demo-1.7.0-SNAPSHOT.zip -d /path/to/openmrs/content/ssuubo/
```

### 3. Configure Content Loading

Create `/path/to/openmrs/openmrs-runtime.properties`:

```properties
# Enable content package loading
content.packages.enabled=true
content.packages.directory=/path/to/openmrs/content/
content.packages.autoLoad=true
```

## Method 3: Docker Integration

### 1. Dockerfile Approach

```dockerfile
FROM openmrs/openmrs-referenceapplication:latest

# Copy content package
COPY target/referenceapplication-demo-1.7.0-SNAPSHOT.zip /openmrs/content/

# Extract content
RUN unzip /openmrs/content/referenceapplication-demo-1.7.0-SNAPSHOT.zip -d /openmrs/content/ssuubo/

# Set permissions
RUN chown -R openmrs:openmrs /openmrs/content/
```

### 2. Docker Compose

```yaml
version: '3.8'
services:
  openmrs:
    image: openmrs/openmrs-referenceapplication:latest
    volumes:
      - ./target/referenceapplication-demo-1.7.0-SNAPSHOT.zip:/openmrs/content/ssuubo.zip
      - ./configuration:/openmrs/configuration
    environment:
      - OPENMRS_CONTENT_PACKAGES=referenceapplication-demo-1.7.0-SNAPSHOT
```

## Configuration Details

### Backend Configuration
Your package includes:
- **Locations** - `/configuration/backend_configuration/locations/`
- **Concepts** - `/configuration/backend_configuration/concepts/`
- **Forms** - `/configuration/backend_configuration/forms/`
- **Metadata** - `/configuration/backend_configuration/metadata/`

### Frontend Configuration
- **SPA Modules** - `/configuration/frontend_configuration/config.json`
- **UI Settings** - Custom frontend configurations

### Dependencies
Update `content.properties` to specify required modules:

```properties
# Required OpenMRS modules
omod.webservices.rest = >= 2.44
omod.appframework = >= 2.15

# Required SPA modules
spa.frontendModules.@openmrs/esm-patient-chart-app = ^5.0
spa.frontendModules.@openmrs/esm-form-engine-app = ^4.0
```

## Verification Steps

### 1. Check Content Loading
```bash
# Check OpenMRS logs
tail -f /path/to/openmrs/logs/openmrs.log | grep "content package"
```

### 2. Verify in OpenMRS UI
1. Navigate to **System Administration → Advanced Settings**
2. Check **Content Packages** section
3. Verify "referenceapplication-demo" is listed and active

### 3. Test Configuration
- Check if locations appear in Location Management
- Verify forms are available in patient forms
- Confirm SPA modules load correctly

## Troubleshooting

### Common Issues

**Content not loading:**
- Verify file permissions
- Check OpenMRS logs for errors
- Ensure content package version matches dependency requirements

**Missing dependencies:**
- Install required OpenMRS modules first
- Verify SPA module compatibility
- Check `content.properties` for correct version constraints

**Configuration conflicts:**
- Review backend configuration files for duplicates
- Check frontend configuration for module conflicts
- Verify database schema compatibility

### Debug Commands
```bash
# Check content package contents
unzip -l referenceapplication-demo-1.7.0-SNAPSHOT.zip

# Verify OpenMRS can read content
curl -u admin:Admin123 "http://localhost:8080/openmrs/ws/rest/v1/contentpackage"

# Check installed modules
curl -u admin:Admin123 "http://localhost:8080/openmrs/ws/rest/v1/module"
```

## Version Management

### For Development
Use SNAPSHOT versions for testing:
```xml
<version>1.7.0-SNAPSHOT</version>
```

### For Production
Use stable release versions:
```xml
<version>1.7.0</version>
```

### Updating Content
1. Update your content package
2. Publish new version using `./publish.sh`
3. Update dependency version in distro `pom.xml`
4. Redeploy your distribution
