
#!/usr/bin/env bash
#
# Script to convert file to UTF-8 Encoding
# Rajendarreddy Jagapathi - 16/Apr/2017
# Usage
# chmod +x create_npm_symlinks.sh
# bash create_npm_symlinks.sh
#enter input encoding here
for i in "$(npm prefix -g)/lib/node_modules/"*; do
  sudo npm build -g "$i"
done
