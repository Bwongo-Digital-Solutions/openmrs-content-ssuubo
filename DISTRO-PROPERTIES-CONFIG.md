# Configuring SSUUBO Content Package via distro.properties

## Overview

Using `distro.properties` is the standard OpenMRS distribution method for including content packages and modules. This approach allows you to define all dependencies in a single configuration file.

## distro.properties Configuration

### 1. Basic Content Package Configuration

```properties
# Distribution metadata
distro.name=SSUUBO OpenMRS Distribution
distro.version=1.0.0
distro.description=Custom OpenMRS distribution with SSUUBO content

# Content package configuration
contentPackage.referenceapplication-demo.groupId=org.openmrs.content
contentPackage.referenceapplication-demo.artifactId=referenceapplication-demo
contentPackage.referenceapplication-demo.version=1.7.0-SNAPSHOT
contentPackage.referenceapplication-demo.type=zip
```

### 2. Complete distro.properties Example

```properties
# === Distribution Information ===
distro.name=SSUUBO OpenMRS Distribution
distro.version=1.0.0
distro.description=Custom OpenMRS distribution with SSUUBO healthcare content
distro.requireOpenmrsVersion=2.5.0

# === OpenMRS Core ===
openmrs.platform.version=2.5.0

# === Content Packages ===
# SSUUBO Content Package
contentPackage.referenceapplication-demo.groupId=org.openmrs.content
contentPackage.referenceapplication-demo.artifactId=referenceapplication-demo
contentPackage.demo.version=1.7.0-SNAPSHOT
contentPackage.referenceapplication-demo.type=zip

# === Backend Modules (OMODs) ===
# Required modules for content package
module.webservices.rest.groupId=org.openmrs.module
module.webservices.rest.artifactId=webservices.rest-2.0
module.webservices.rest.version=2.44.0
module.webservices.rest.startup=true

module.appframework.groupId=org.openmrs.module
module.appframework.artifactId=appframework-2.0
module.appframework.version=2.15.0
module.appframework.startup=true

module.uiframework.groupId=org.openmrs.module
module.uiframework.artifactId=uiframework-2.0
module.uiframework.version=3.15.0
module.uiframework.startup=true

module.reporting.groupId=org.openmrs.module
module.reporting.artifactId=reporting-2.0
module.reporting.version=2.3.0
module.reporting.startup=true

module.htmlformentry.groupId=org.openmrs.module
module.htmlformentry.artifactId=htmlformentry-2.0
module.htmlformentry.version=3.14.0
module.htmlformentry.startup=true

# === Frontend Modules (SPA) ===
spa.@openmrs/esm-patient-chart-app.version=5.0.0
spa.@openmrs/esm-form-engine-app.version=4.0.0
spa.@openmrs/esm-generic-patient-widgets-app.version=7.0.0
spa.@openmrs/esm-appointment-scheduling-app.version=2.0.0

# === Repository Configuration ===
maven.repo.id=openmrs-public
maven.repo.url=https://mavenrepo.openmrs.org/public
maven.snapshot.repo.id=openmrs-snapshots
maven.snapshot.repo.url=https://mavenrepo.openmrs.org/snapshots

# === Optional Configuration ===
# Database configuration (can be overridden)
db.driver=com.mysql.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/openmrs?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8&sessionVariables=storage_engine=InnoDB
db.username=openmrs
db.password=openmrs

# Connection pool settings
connection.pool.maxActive=40
connection.pool.maxIdle=20
connection.pool.minIdle=5
connection.pool.testOnBorrow=true
connection.pool.validationQuery=SELECT 1

# Module loading configuration
module.loading.enabled=true
module.loading.autoUpdate=true
module.loading.warnOnStartup=true

# Content package loading
content.packages.enabled=true
content.packages.autoLoad=true
content.packages.failOnError=true
```

### 3. Minimal distro.properties for Content Package Only

```properties
# Distribution info
distro.name=SSUUBO Content Distribution
distro.version=1.0.0
distro.requireOpenmrsVersion=2.5.0

# OpenMRS Core
openmrs.platform.version=2.5.0

# SSUUBO Content Package
contentPackage.referenceapplication-demo.groupId=org.openmrs.content
contentPackage.referenceapplication-demo.artifactId=referenceapplication-demo
contentPackage.referenceapplication-demo.version=1.7.0-SNAPSHOT
contentPackage.referenceapplication-demo.type=zip

# Essential modules only
module.webservices.rest.groupId=org.openmrs.module
module.webservices.rest.artifactId=webservices.rest-2.0
module.webservices.rest.version=2.44.0
module.webservices.rest.startup=true

# Repository
maven.repo.id=openmrs-public
maven.repo.url=https://mavenrepo.openmrs.org/public
maven.snapshot.repo.id=openmrs-snapshots
maven.snapshot.repo.url=https://mavenrepo.openmrs.org/snapshots
```

## Integration Steps

### 1. Create Distribution Project Structure

```
my-ssuubo-distro/
├── pom.xml
├── distro.properties
└── README.md
```

### 2. Create pom.xml for Distribution

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.ssuubo</groupId>
    <artifactId>ssuubo-openmrs-distro</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>
    
    <name>SSUUBO OpenMRS Distribution</name>
    <description>Custom OpenMRS distribution with SSUUBO content</description>
    
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <openmrs.platform.version>2.5.0</openmrs.platform.version>
    </properties>
    
    <dependencies>
        <!-- OpenMRS Core -->
        <dependency>
            <groupId>org.openmrs</groupId>
            <artifactId>openmrs-webapp</artifactId>
            <version>${openmrs.platform.version}</version>
            <type>war</type>
        </dependency>
        
        <!-- Content Package -->
        <dependency>
            <groupId>org.openmrs.content</groupId>
            <artifactId>referenceapplication-demo</artifactId>
            <version>1.7.0-SNAPSHOT</version>
            <type>zip</type>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.openmrs.maven.plugins</groupId>
                <artifactId>maven-openmrs-plugin</artifactId>
                <version>2.2.0</version>
                <configuration>
                    <distroFile>distro.properties</distroFile>
                </configuration>
            </plugin>
        </plugins>
    </build>
    
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
</project>
```

### 3. Build and Deploy Distribution

```bash
# Build the distribution
mvn clean install

# Run the distribution
mvn openmrs:run

# Or create deployable package
mvn package
```

## Advanced Configuration

### 1. Conditional Content Loading

```properties
# Load content package only in specific environments
contentPackage.referenceapplication-demo.condition=${env.type}==production

# Environment-specific versions
contentPackage.referenceapplication-demo.version.development=1.7.0-SNAPSHOT
contentPackage.referenceapplication-demo.version.production=1.7.0
```

### 2. Content Package Overrides

```properties
# Override specific configuration files
contentPackage.referenceapplication-demo.override.locations=true
contentPackage.referenceapplication-demo.override.concepts=false

# Custom configuration directory
contentPackage.referenceapplication-demo.configDir=/custom/ssuubo-config
```

### 3. Module Dependencies

```properties
# Ensure modules load before content package
module.webservices.rest.startup=true
module.appframework.startup=true
contentPackage.referenceapplication-demo.loadAfter=webservices.rest,appframework
```

## Verification

### 1. Check Distribution Configuration

```bash
# Validate distro.properties
mvn openmrs:validate-distro

# Show resolved dependencies
mvn dependency:tree
```

### 2. Verify Content Loading

```bash
# Check OpenMRS logs for content loading
tail -f target/openmrs/logs/openmrs.log | grep "SSUUBO\|referenceapplication-demo"
```

### 3. Test in Browser

1. Navigate to `http://localhost:8080/openmrs`
2. Check **System Administration → Advanced Settings**
3. Verify content package is listed under **Content Packages**

## Troubleshooting

### Common Issues

**Content package not found:**
- Verify Maven repository access
- Check content package version and coordinates
- Ensure `type=zip` is specified

**Module conflicts:**
- Verify module versions are compatible
- Check module startup order
- Review dependency constraints

**Configuration errors:**
- Validate `distro.properties` syntax
- Check for missing required properties
- Verify repository URLs are accessible

### Debug Commands

```bash
# Test Maven resolution
mvn dependency:resolve -Dclassifier=sources

# Validate distro configuration
mvn openmrs:help -Ddetail=true -Dgoal=run

# Check content package metadata
unzip -l ~/.m2/repository/org/openmrs/content/referenceapplication-demo/1.7.0-SNAPSHOT/referenceapplication-demo-1.7.0-SNAPSHOT.zip
```
