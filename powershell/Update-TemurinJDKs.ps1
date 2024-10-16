# Set the directory where the script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the JDK installation paths (update these as per your environment)
$JdkPaths = @{
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
$BackupDir = Join-Path -Path $ScriptDir -ChildPath "backup"
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

# Function to get the download URL for the latest JDK version
function Get-JDKDownloadUrl {
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
    
    # Check for a valid download URL for the ZIP package
    $jdkPackage = $response | Where-Object { $_.binary.package.name -like "*.zip" }

    if ($jdkPackage) {
        $downloadUrl = $jdkPackage.binary.package.link
        $releaseVersion = $jdkPackage.version.openjdk_version
        
        # Return both the download URL and the release version
        return @{
            DownloadUrl = $downloadUrl;
            # Strip everything after the first '-'
            ReleaseVersion = $releaseVersion -replace '[-+].*', ''
        }
    } else {
        Write-Host "No valid ZIP package found for JDK $Version"
        return $null
    }
}

# Function to check if JDK is already up-to-date
function Is-JDKUpToDate {
    param (
        [string]$Version,
        [string]$CurrentJdkPath,
        [string]$LatestVersion
    )

    if (Test-Path $CurrentJdkPath) {
        $installedVersion = & "$CurrentJdkPath" -version 2>&1 | Select-String -Pattern 'version "(.+?)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        if ($installedVersion -eq $LatestVersion) {
            Write-Host "JDK $Version is up to date (Installed: $installedVersion, Latest: $LatestVersion). Skipping download."
            return $true
        } else {
            Write-Host "JDK $Version is outdated (Installed: $installedVersion, Latest: $LatestVersion)."
        }
    } else {
        Write-Host "JDK $Version is not installed."
    }

    return $false
}

# Function to back up the existing JDK to the "oldjdk" directory
function Backup-ExistingJDK {
    param (
        [string]$Version,
        [string]$OldJdkDir,
        [string]$BackupDir
    )

    $OldJdkBackupDir = Join-Path -Path $BackupDir -ChildPath "oldjdk-$Version"

    if (Test-Path $OldJdkDir) {
        Write-Host "Backing up existing JDK $Version to $OldJdkBackupDir..."

        if (Test-Path $OldJdkBackupDir) {
            Remove-Item -Path $OldJdkBackupDir -Recurse -Force
        }

        Copy-Item -Path $OldJdkDir -Destination $OldJdkBackupDir -Recurse -Force
        Write-Host "Backup of JDK $Version completed."
    } else {
        Write-Host "No existing JDK $Version found for backup."
    }
}

# Function to download the JDK zip file
function Download-JDK {
    param (
        [string]$DownloadUrl,
        [string]$ZipFilePath
    )

    Write-Host "Downloading JDK to $ZipFilePath..."

    Start-BitsTransfer -Source $DownloadUrl -Destination $ZipFilePath -ErrorAction Stop
    Write-Host "Downloaded JDK to $ZipFilePath"
}

# Function to extract the JDK using 7-Zip
function Extract-JDKWith7Zip {
    param (
        [string]$ZipFilePath,
        [string]$ExtractDir,
        [string]$SevenZipPath
    )
    $TempExtractDir = Join-Path -Path $ExtractDir -ChildPath "temp"
    Write-Host "Extracting JDK from $ZipFilePath to temporary directory $TempExtractDir using 7-Zip..."

    # Clean up any existing extraction directory
    if (Test-Path $TempExtractDir) {
        Remove-Item -Path $TempExtractDir -Recurse -Force
    }

    if (Test-Path $ExtractDir) {
        Remove-Item -Path $ExtractDir -Recurse -Force
    }

    # Extract to temporary directory
    & "$SevenZipPath" x "$ZipFilePath" -o"$TempExtractDir" -y | Out-Null

    # Find the root directory inside the extracted contents
    $innerDir = Get-ChildItem -Path $TempExtractDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1

    if ($innerDir) {
        Write-Host "Moving extracted contents from $innerDir to $ExtractDir..."

        # Move the contents to the final directory
        Move-Item -Path "$($innerDir.FullName)\*" -Destination $ExtractDir -Force

        # Remove the temporary directory
        Remove-Item -Path $TempExtractDir -Recurse -Force

        Write-Host "Extraction completed to $ExtractDir."
    } else {
        Write-Host "No root directory found inside the extracted archive."
    }
}

# Function to copy the old cacerts file to the new JDK
function Copy-Cacerts {
    param (
        [string]$BackupCacerts,
        [string]$ExtractedJdkDir
    )

    $CacertsPath = Join-Path -Path $ExtractedJdkDir -ChildPath "lib\security\cacerts"
    if (Test-Path $BackupCacerts) {
        Copy-Item -Path $BackupCacerts -Destination $CacertsPath -Force
        Write-Host "Copied cacerts for the JDK."
    } else {
        Write-Host "No cacerts backup found."
    }
}

# Function to add root certificate to cacerts
function Add-RootCert {
    param (
        [string]$KeytoolPath,
        [string]$CacertsPath,
        [string]$RootCert
    )

    Write-Host "Adding root certificate to cacerts..."

    & "$KeytoolPath" -importcert -noprompt -trustcacerts -keystore "$CacertsPath" -storepass "changeit" -alias "rootcert" -file "$RootCert"
    Write-Host "Added root certificate to cacerts."
}

# Main function to update the JDK
function Update-JDK {
    param (
        [string]$Version,
        [string]$OldJdkDir,
        [string]$BackupDir,
        [string]$DownloadDir,
        [string]$ExtractDir,
        [string]$SevenZipPath,
        [string]$RootCert
    )

    # Get download URL
    $jdkInfo = Get-JDKDownloadUrl -Version $Version
    $DownloadUrl = $jdkInfo["DownloadUrl"]
    $releaseVersion = $jdkInfo["ReleaseVersion"]
    if (-not $DownloadUrl) { return }

    # Set file paths
    $ZipFilePath = Join-Path -Path $DownloadDir -ChildPath "temurin-$Version.zip"

    # Check if JDK is up-to-date
    $CurrentJdkPath = Join-Path -Path $OldJdkDir -ChildPath "bin\java.exe"
    if (Is-JDKUpToDate -Version $Version -CurrentJdkPath $CurrentJdkPath -LatestVersion $releaseVersion) {
        return
    }

    # Backup old JDK
    Backup-ExistingJDK -Version $Version -OldJdkDir $OldJdkDir -BackupDir $BackupDir

    # Download JDK
    Download-JDK -DownloadUrl $DownloadUrl -ZipFilePath $ZipFilePath

    # Extract JDK using 7-Zip
    Extract-JDKWith7Zip -ZipFilePath $ZipFilePath -ExtractDir $ExtractDir -SevenZipPath $SevenZipPath

    # Copy old cacerts
    $BackupCacerts = Join-Path -Path $BackupDir -ChildPath "cacerts_jdk$Version"
    Copy-Cacerts -BackupCacerts $BackupCacerts -ExtractedJdkDir $ExtractDir

    # Add root certificate
    $KeytoolPath = Join-Path -Path $ExtractDir -ChildPath "bin\keytool.exe"
    Add-RootCert -KeytoolPath $KeytoolPath -CacertsPath (Join-Path -Path $ExtractDir -ChildPath "lib\security\cacerts") -RootCert $RootCert
}

# Example usage:
#$DownloadDir = "C:\tmp\jdk_download"
#$BackupDir = "C:\tmp\backup"
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
#$RootCert = "C:\path\to\root.cer"
#$JdkPaths = @{
#    "8" = "C:\Program Files\Java\jdk1.8.0_xxx"
#    "11" = "C:\Program Files\Java\jdk-11.x.x"
#    "17" = "C:\Program Files\Java\jdk-17.x.x"
#    "21" = "C:\Program Files\Java\jdk-21.x.x"
#}

# Call the function for the desired JDK version (e.g., 8)
#Update-JDK -Version "8" -OldJdkDir $OldJdkPaths["8"] -BackupDir $BackupDir -DownloadDir $DownloadDir -SevenZipPath $SevenZipPath -RootCert $RootCert

# JDK versions to download and update
$JdkVersions = @("8", "11", "17", "21")

# Process each JDK version
foreach ($version in $JdkVersions) {
    Update-JDK -Version $version -OldJdkDir $JdkPaths[$version] -BackupDir $BackupDir -DownloadDir $DownloadDir -ExtractDir $JdkPaths[$version] -SevenZipPath $SevenZipPath -RootCert $RootCert
}

# Clean up the downloaded files
Remove-Item -Recurse -Force $DownloadDir

Write-Host "All JDKs installed and root certificate added successfully."
