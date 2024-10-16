# Set the directory where the script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the old JDK installation paths (update these as per your environment)
$OldJdkPaths = @{
    "8"  = "C:\apps\java\jdk-8"
    "11" = "C:\apps\java\jdk-11"
    "17" = "C:\apps\java\jdk-17"
    "21" = "C:\apps\java\jdk-21"
}

# Set the root certificate file path
$RootCert = Join-Path -Path $ScriptDir -ChildPath "Zscaler_root.cer"

# Ensure the root certificate exists
if (-not (Test-Path $RootCert)) {
    Write-Host "Root certificate file (Zscaler_root.cer) not found in script directory."
    exit 1
}

# Create a temporary directory for downloads
$DownloadDir = Join-Path -Path $env:TEMP -ChildPath "jdk_downloads"
if (-not (Test-Path $DownloadDir)) {
    New-Item -Path $DownloadDir -ItemType Directory | Out-Null
}

# Backup cacerts directory
$BackupDir = Join-Path -Path $ScriptDir -ChildPath "cacerts_backup"
if (-not (Test-Path $BackupDir)) {
    New-Item -Path $BackupDir -ItemType Directory | Out-Null
}

# Backup old JDK cacerts files
foreach ($version in $OldJdkPaths.Keys) {
    $OldJdkCacerts = Join-Path -Path $OldJdkPaths[$version] -ChildPath "lib\security\cacerts"
    if (Test-Path $OldJdkCacerts) {
        Copy-Item -Path $OldJdkCacerts -Destination (Join-Path -Path $BackupDir -ChildPath "cacerts_jdk$version") -Force
        Write-Host "Backed up cacerts for JDK $version"
    } else {
        Write-Host "cacerts file not found for JDK $version"
    }
}

# Function to download, extract, and update JDKs
function Download-Extract-UpdateJDK {
    param (
        [string]$Version
    )

    # Set the API URL to get the latest JDK version
    $ApiUrl = "https://api.adoptium.net/v3/assets/latest/$Version/hotspot?release_type=ga&jvm_impl=hotspot&image_type=jdk&os=windows&architecture=x64"
    
    Write-Host "Fetching download URL for JDK $Version from $ApiUrl..."

    # Get the download URL for the ZIP file
    $response = Invoke-RestMethod -Uri $ApiUrl -ErrorAction Stop

    # Output the entire response for debugging
    #Write-Host "API Response: $($response | ConvertTo-Json -Depth 10)"
    
    # Parse the response to find the ZIP package
    $downloadUrl = ($response.binary | Where-Object { $_.image_type -eq "jdk" -and $_.package.name -like "*.zip" }).package.link

    if (-not $downloadUrl) {
        Write-Host "Failed to retrieve download URL for JDK $Version"
        return
    }

    Write-Host ("Download URL for JDK {0}: {1}" -f $Version, $downloadUrl)

    # Download the ZIP file
    $zipFile = Join-Path -Path $DownloadDir -ChildPath "temurin-$Version.zip"
    Write-Host "Downloading JDK $Version to $zipFile..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "Downloaded JDK $Version"

    # Extract the ZIP file
    $ExtractedJdkDir = Join-Path -Path $ScriptDir -ChildPath "jdk-$Version"
    Write-Host "Extracting JDK $Version..."
    Expand-Archive -Path $zipFile -DestinationPath $ExtractedJdkDir -Force
    Write-Host "Extracted JDK $Version"

    # Copy old cacerts to new JDK
    $BackupCacerts = Join-Path -Path $BackupDir -ChildPath "cacerts_jdk$Version"
    if (Test-Path $BackupCacerts) {
        Copy-Item -Path $BackupCacerts -Destination (Join-Path -Path $ExtractedJdkDir -ChildPath "lib\security\cacerts") -Force
        Write-Host "Copied cacerts for JDK $Version"
    } else {
        Write-Host "No cacerts backup found for JDK $Version"
    }

    # Add root certificate to the new cacerts
    $KeytoolPath = Join-Path -Path $ExtractedJdkDir -ChildPath "bin\keytool.exe"
    $CacertsPath = Join-Path -Path $ExtractedJdkDir -ChildPath "lib\security\cacerts"
    & "$KeytoolPath" -importcert -noprompt -trustcacerts -keystore "$CacertsPath" -storepass "changeit" -alias "rootcert" -file "$RootCert"
    Write-Host "Added root certificate to JDK $Version cacerts"
}

# JDK versions to download and update
$JdkVersions = @("8", "11", "17", "21")

# Process each JDK version
foreach ($version in $JdkVersions) {
    Download-Extract-UpdateJDK -Version $version
}

# Clean up the downloaded files
Remove-Item -Recurse -Force $DownloadDir

Write-Host "All JDKs installed and root certificate added successfully."
