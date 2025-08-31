#!/bin/bash

# Répertoire du script
rep_script="$(dirname "$0")"
keep="updater.sh"

echo "Updating the modpack..."

git clone https://github.com/ClementMR/mythisky_modpack.git temp

if [ ! -d "$rep_script/temp" ]; then
    echo "Unable to clone the repo"
    exit 1
fi

for element in "$rep_script"/*; do
    filename=$(basename "$element")

    if [[ "$filename" != "$keep" && "$filename" != "temp" ]]; then
        rm -rf "$element"
    fi
done

mv "$rep_script/temp"/* "$rep_script"/

rm -rf "$rep_script/temp"

echo "Modpack updated!"