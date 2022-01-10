# Download latest build (build= can be stable or insider)
curl.exe -L "https://api.adoptium.net/v3/binary/latest/8/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk" -o "jdk-8.zip"

# Delete anything except user data, update script and downloaded zip file
Get-ChildItem -Exclude @("updatejdk.ps1", "jdk-8.zip") | Remove-Item -Recurse -Force

# Unzip it
Expand-Archive -Path "jdk-8.zip" -DestinationPath .

# Move Files to Parent directory from Extracted Directory
Move-Item -Path "./jdk8u*/*" -Destination .

# Delete downloaded package and Extracted Directory
Remove-Item -Path ("jdk-8.zip", "jdk8u*")
Pause
