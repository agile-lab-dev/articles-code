#!/bin/bash
set -e

################
# DO NOT USE THIS SCRIPT DIRECTLY. INSTEAD USE carbon-image-generator.sh
################

# Needed since carbon-now is slow
sleep_time=0
carbon_url="https://carbon.now.sh"
embedded_carbon_url="${carbon_url}/embed"
code_delimiter="§"
tmp_splitted_file_location="${PWD}/.temporary"

# Taken from an image on the Carbon web app, after importing a preset config
encoded_template="bg=rgba%28171%2C+184%2C+195%2C+1%29&t=blackboard&wt=none&l=text%2Fx-scala&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=56px&ph=56px&ln=false&fl=1&fm=Hack&fs=14px&lh=133%25&si=false&es=2x&wm=false"

GREEN_COLOR='\e[32m'
RED_COLOR='\e[31m'
NC='\e[39m' # No Color

USAGE="""Usage:
-h|--help                          Print this help and exit
-i|--input <path>                  Path to the folder containing the source code files. Only scala sources are properly
                                   formatted
-p|--preset <path>                 Path to the preset file to be used with carbon-now CLI. Should be a JSON file
"""

function print_usage_and_exit() {
  echo "${USAGE}"
  exit ${1}
}

# utility for checking whether a variable is set to a non-empty value using bash black magic
function is_variable_unset_or_empty() {
  VARIABLE_NAME=${1}
  eval '[[ -z "${!VARIABLE_NAME+something}" || "${!VARIABLE_NAME}" = "" ]]'
}

urlencode() {
  # urlencode <string>

  old_lc_collate=$LC_COLLATE
  LC_COLLATE=C

  local length="${#1}"
  for ((i = 0; i < length; i++)); do
    local c="${1:$i:1}"
    case $c in
    [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
    *) printf '%%%02X' "'$c" ;;
    esac
  done

  LC_COLLATE=$old_lc_collate
}

while [[ $# -gt 0 ]]; do
  ARG=$1
  case $ARG in
  -h | --help)
    print_usage_and_exit 0
    ;;
  -i | --input)
    shift
    SOURCES_PATH="${1}"
    shift
    ;;
  -p | --preset)
    shift
    CARBON_PRESET="${1}"
    shift
    ;;
  *)
    echo "Unrecognized option \"$ARG\""
    print_usage_and_exit 1
    ;;
  esac
done

if is_variable_unset_or_empty SOURCES_PATH; then
  echo "Error: The sources path parameter must be set"
  print_usage_and_exit 2
fi

if is_variable_unset_or_empty CARBON_PRESET; then
  echo "Error: The preset file for Carbon must be set"
  print_usage_and_exit 3
fi

echo "SCRIPT PARAMS:"
echo "SOURCES_PATH = $SOURCES_PATH"
echo "CARBON_PRESET = $CARBON_PRESET"

embedded_images_links_path="${SOURCES_PATH}/embedded_images_links"
declare -a embedded_images_list=()

files=$(ls "${SOURCES_PATH}/")

subsection_count=0
for source_code_file_name in ${files}; do
  source_code_absolute_path="${SOURCES_PATH}/${source_code_file_name}"

  # Takes the file name and deletes the longest matched substring (until a dot) starting from the end
  # Folder/Filename.extension -> Filename
  file_basename=$(basename "${source_code_absolute_path}")
  partial_target_file_name=${file_basename%%.*}

  echo "Generating embedded a non-embedded image for input file: ${source_code_absolute_path}"

  # Reads the file contents
  file_contents=$(<"${source_code_absolute_path}")

  # Check if we should split output onto more parts
  if [[ ${file_contents} =~ ${code_delimiter} ]]; then
    file_contains_delimiter=true
  else
    file_contains_delimiter=false
  fi

  originalIFS=${IFS}
  IFS="${code_delimiter}"
  for code_section in ${file_contents}; do
    # If the section is not empty
    if [[ ${#code_section} != 0 ]]; then

      if [[ "${file_contains_delimiter}" = true ]]; then
        target_file_name="${partial_target_file_name}_part${subsection_count}"
      else
        target_file_name="${partial_target_file_name}"
      fi

      # Removes trailing spaces and leading/trailing whitespaces
      trimmed_code="$(sed -e 's/[[:space:]]*$//' -e :a -e '/./,$!d;/^\n*$/{$d;N;};/\n$/ba' <<< "${code_section}")"
      # We write the trimmed code into a temp file
      echo "$trimmed_code" >"${tmp_splitted_file_location}"

      encoded_source_code=$(urlencode "${trimmed_code}")

      embedded_image="${embedded_carbon_url}?${encoded_template}&code=${encoded_source_code}"

      embedded_image_output_console="${GREEN_COLOR}${target_file_name} ${RED_COLOR} ----> ${NC} ${embedded_image}"

      embedded_image_output_file="${target_file_name} ----> ${embedded_image}"
      embedded_images_list+=("${embedded_image_output_file}")

      echo -e "${embedded_image_output_console}"
      eval "carbon-now '${tmp_splitted_file_location}' -h -p ${CARBON_PRESET} -l '${SOURCES_PATH}' -t '${target_file_name}'"

      rm "${tmp_splitted_file_location}"
      subsection_count=$((subsection_count + 1))
      sleep ${sleep_time}
    fi
  done
  IFS=${originalIFS}

  subsection_count=0
done

printf '%s\n' "${embedded_images_list[@]}" >"${embedded_images_links_path}"

echo -e "${GREEN_COLOR}------${NC}"
echo -e "The embedded images links are saved in ${RED_COLOR}${embedded_images_links_path}"
echo -e "${GREEN_COLOR}------${NC}"
