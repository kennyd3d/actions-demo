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
    # Initialize an empty options string
    options_string=""

    # Build the options string, appending a comma only when needed
    for option in "${output_array[@]}"; do
        options_string+="$option, "
    done

    # Remove the trailing comma and space
    options_string="${options_string%, }"

    # Wrap the options string in square brackets
    options_string="[$options_string]"

    echo "opts: $options_string"

    yq eval ".on.workflow_dispatch.inputs.RELEASE.options = \"$options_string\"" -i $SOURCE_YAML_FILE


fi