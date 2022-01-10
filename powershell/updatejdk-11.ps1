# Download latest build (build= can be stable or insider)
curl.exe -L "https://api.adoptium.net/v3/binary/latest/11/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk" -o "jdk-11.zip"

# Delete anything except user data, update script and downloaded zip file
Get-ChildItem -Exclude @("updatejdk.ps1", "jdk-11.zip") | Remove-Item -Recurse -Force

# Unzip it
Expand-Archive -Path "jdk-11.zip" -DestinationPath .

# Move Files to jdk8 directory
Move-Item -Path "./jdk-11*/*" -Destination .

# Delete downloaded package and Extracted Directory
Remove-Item -Path ("jdk-11.zip", "jdk-11*")
Pause
