#!/bin/bash
SOURCE_YAML_FILE="./.github/workflows/dev.yml"

echo "Release Names: $RELEASE_NAMES"

OPTIONS=($RELEASE_NAMES)


current_options=$(yq eval '.on.workflow_dispatch.inputs.RELEASE.options' $SOURCE_YAML_FILE )

echo "current: $current_options"

current_options_array=()
while read -r word; do
    current_options_array+=("$word")
done <<< "$current_options"


declare -a output_array=()

# Use "${OPTIONS[@]}" to correctly iterate over array elements
for i in "${OPTIONS[@]}"; do
    echo "op: $i"
    output_array+=("$i")
done


# Check if the values in the arrays are equal
if [[ "${current_options_array[*]}" == "${output_array[*]}" ]]; then
    echo "Values in YAML file are equal to values in array. No update needed."
else
    echo "Values in YAML file are not equal to values in array. Updating YAML file."
    
    # Build the YAML list with correct formatting
    yq eval '.on.workflow_dispatch.inputs.RELEASE.options = []' -i $SOURCE_YAML_FILE
    for option in "${output_array[@]}"; do
        yq eval ".on.workflow_dispatch.inputs.RELEASE.options += \"$option\"" -i $SOURCE_YAML_FILE
    done
fi