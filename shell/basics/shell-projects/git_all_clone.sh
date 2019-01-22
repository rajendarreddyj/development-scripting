
#!/usr/bin/env bash
# A Simple Shell Script To do git pull on all repositories in directories and sub directories
# Rajendarreddy Jagapathi - 21/Jan/2019
# Usage
# chmod +x git_all_clone.sh
for i in $(curl "https://api.github.com/orgs/[organization]/repos?access_token=[access_token]" | sed '/[ ]*"clone_url":/!d;s/[^:]*: "//;s/",$//'); do
  echo git clone $i
done
