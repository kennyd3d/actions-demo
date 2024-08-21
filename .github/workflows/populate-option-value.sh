#!/bin/bash
SOURCE_YAML_FILE="./.github/workflows/dev.yml"


# dynamically generate values.
# ex. could read repository or file to get values
OPTIONS=($(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <GH-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/kennyd3d/actions-demo/releases | \
  grep '"name":' | \
  sed -E 's/.*"name": "(.*)".*/\1/' | \
  awk '{print $1}'))

echo "${OPTIONS[@]}"

OPTIONS=(0.0.8 0.0.7)


current_options=$(yq eval '.on.workflow_dispatch.inputs.version.options' $SOURCE_YAML_FILE )


current_options_array=()
while read -r word; do
    current_options_array+=("$word")
done <<< "$current_options"


declare -a output_array=()


for i in $OPTIONS; do
    output_array+=("$i")
done


# Check if the values in the arrays are equal
if [[ "${current_options_array[*]}" == "${output_array[*]}" ]]; then
    echo "Values in YAML file are equal to values in array. No update needed."
else
    echo "Values in YAML file are not equal to values in array. Updating YAML file."
    # Construct YAML-compatible string
    options_string="["


    for option in "${output_array[@]}"; do
        options_string+="\\"$option\\", "
    done


    options_string="${options_string%, }]"


    yq eval ".on.workflow_dispatch.inputs.version.options = $options_string" $SOURCE_YAML_FILE > temp.yml && mv temp.yml $SOURCE_YAML_FILE
fi

