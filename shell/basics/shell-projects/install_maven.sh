#!/bin/bash

# Define the Maven version you want to download
MAVEN_VERSION=3.9.5
MAVEN_DIR="/usr/share/maven-$MAVEN_VERSION"

# Define the URL for the Maven binary tarball
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz"

# Download Maven
echo "Downloading Maven $MAVEN_VERSION..."
wget $MAVEN_URL -O /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz

# Create the Maven version-specific directory if it doesn't exist
if [ ! -d "$MAVEN_DIR" ]; then
  echo "Creating directory $MAVEN_DIR..."
  mkdir -p $MAVEN_DIR
fi

# Extract Maven to the version-specific directory
echo "Extracting Maven..."
tar -xzf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR --strip-components=1

# Clean up the downloaded tar file
rm /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz

# Check if Maven was successfully installed
echo "Maven installed in $MAVEN_DIR. Checking installation..."
$MAVEN_DIR/bin/mvn -version

echo "Maven installation completed."
