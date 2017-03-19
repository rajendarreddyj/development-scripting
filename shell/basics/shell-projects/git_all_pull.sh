#!/usr/bin/env bash
# A Simple Shell Script To do git pull on all repositories in directories and sub directories
# Rajendarreddy Jagapathi - 23/Jan/2017
# Usage
# chmod +x git_all_pull.sh
# bash git_all_pull.sh
find . -name ".git" -type d | sed 's/\/.git//' |  xargs -P10 -I{} git -C {} pull
exit 0
