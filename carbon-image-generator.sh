#!/usr/bin/env bash

################
# Please run this script from the repository's root directory
################

DOCKER_RESOURCES_DIR="_internal_carbon_resources"
CARBON_DOCKER_ROOT_DIR="/home/carbon"
CARBON_DOCKER_SOURCE_DIR="${CARBON_DOCKER_ROOT_DIR}/sources"
CARBON_INNER_SCRIPT="${DOCKER_RESOURCES_DIR}/carbon-image-generator-inner-docker-script.sh"
CARBON_PRESET_CONFIG="${DOCKER_RESOURCES_DIR}/carbon-now-cli-preset.json"
CARBON_PRESET_TYPE="article"

source ${DOCKER_RESOURCES_DIR}/get-docker-cmd.sh

function print_usage_and_exit {
    echo "${USAGE}"
    exit ${1}
}

# utility for checking whether a variable is set to a non-empty value using bash black magic
function is_variable_unset_or_empty {
    VARIABLE_NAME=${1}
    eval '[[ -z "${!VARIABLE_NAME+something}" || "${!VARIABLE_NAME}" = "" ]]'
}

USAGE="""Usage:
-h|--help                          Print this help and exit
-s|--sources <path>                Path to the folder containing the source code files. Only Scala sources are properly
                                   formatted
"""

while [[ $# -gt 0 ]]; do
    ARG=$1
    case $ARG in
        -h|--help)
            print_usage_and_exit 0
        ;;
        -s|--sources)
            shift
            SOURCES_PATH="${1}"
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

${DOCKER_CMD} build -t carbon-image-generator --build-arg CARBON_ROOT_DIR=${CARBON_DOCKER_ROOT_DIR} .

RUN_COMMAND="${CARBON_DOCKER_ROOT_DIR}/${CARBON_INNER_SCRIPT} --input ${CARBON_DOCKER_SOURCE_DIR} --preset ${CARBON_PRESET_TYPE}"

ABSOLUTE_SOURCES_PATH=$(readlink -e "${SOURCES_PATH}")

${DOCKER_CMD} run --network=host \
--mount "src=${ABSOLUTE_SOURCES_PATH},dst=${CARBON_DOCKER_SOURCE_DIR},type=bind" \
--mount "src=${PWD}/${CARBON_PRESET_CONFIG},dst=${CARBON_DOCKER_ROOT_DIR}/.carbon-now.json,type=bind" \
--mount "src=${PWD}/${CARBON_INNER_SCRIPT},dst=${CARBON_DOCKER_ROOT_DIR}/${CARBON_INNER_SCRIPT},type=bind" \
--privileged \
--user carbon \
--rm \
carbon-image-generator \
/bin/bash -c "${RUN_COMMAND}"

