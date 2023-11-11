#!/bin/bash

FILE="infrastructure/configuration/inventory/hosts.yml"
if ! git diff --exit-code --quiet "$FILE"; then
  git add $FILE
  git commit -m "chore(infrastructure): update inventory hosts file [ci skip]"
  git push
fi