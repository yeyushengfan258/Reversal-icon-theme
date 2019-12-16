#!/bin/bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Reversal
COLOR_VARIANTS=('' '-dark')
THEME_VARIANTS=('' '-red' '-pink' '-purple' '-blue' '-green' '-orange' '-brown' '-grey' '-black')

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}

  local THEME_DIR=${dest}/${name}${theme}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                             ${THEME_DIR}
  cp -r ${SRC_DIR}/COPYING                                                             ${THEME_DIR}
  cp -r ${SRC_DIR}/AUTHORS                                                             ${THEME_DIR}
  cp -r ${SRC_DIR}/src/index.theme                                                     ${THEME_DIR}

  cd ${THEME_DIR}
  sed -i "s/${name}/${name}${theme}${color}/g" index.theme

  if [[ ${color} == '' ]]; then
    cp -r ${SRC_DIR}/src/{16,22,24,32,scalable,symbolic}                               ${THEME_DIR}
    cp -r ${SRC_DIR}/links/{16,22,24,32,scalable,symbolic}                             ${THEME_DIR}
  fi

  if [[ ${color} == '' && ${theme} != '' ]]; then
    cp -r ${SRC_DIR}/src/colors/color${theme}/*.svg                                    ${THEME_DIR}/scalable/places
  fi

  if [[ ${color} == '-dark' ]]; then
    mkdir -p                                                                           ${THEME_DIR}/16
    mkdir -p                                                                           ${THEME_DIR}/22
    mkdir -p                                                                           ${THEME_DIR}/24
    cp -r ${SRC_DIR}/src/16/{actions,devices,places}                                   ${THEME_DIR}/16
    cp -r ${SRC_DIR}/src/22/actions                                                    ${THEME_DIR}/22
    cp -r ${SRC_DIR}/src/24/actions                                                    ${THEME_DIR}/24

    # Change icon color for dark theme
    sed -i "s/#5d656b/#d3dae3/g" "${THEME_DIR}"/{16,22,24}/actions/*
    sed -i "s/#808080/#d3dae3/g" "${THEME_DIR}"/16/{places,devices}/*

    cp -r ${SRC_DIR}/links/16/{actions,devices,places}                                 ${THEME_DIR}/16
    cp -r ${SRC_DIR}/links/22/actions                                                  ${THEME_DIR}/22
    cp -r ${SRC_DIR}/links/24/actions                                                  ${THEME_DIR}/24

    cd ${dest}
    ln -sr ${name}${theme}/scalable ${name}${theme}-dark/scalable
    ln -sr ${name}${theme}/symbolic ${name}${theme}-dark/symbolic
    ln -sr ${name}${theme}/32 ${name}${theme}-dark/32
    ln -sr ${name}${theme}/16/mimetypes ${name}${theme}-dark/16/mimetypes
    ln -sr ${name}${theme}/16/panel ${name}${theme}-dark/16/panel

    ln -sr ${name}${theme}/16/status ${name}${theme}-dark/16/status
    ln -sr ${name}${theme}/22/emblems ${name}${theme}-dark/22/emblems
    ln -sr ${name}${theme}/22/mimetypes ${name}${theme}-dark/22/mimetypes
    ln -sr ${name}${theme}/22/panel ${name}${theme}-dark/22/panel

    ln -sr ${name}${theme}/24/animations ${name}${theme}-dark/24/animations
    ln -sr ${name}${theme}/24/panel ${name}${theme}-dark/24/panel
  fi

  cd ${THEME_DIR}
  ln -sr 16 16@2x
  ln -sr 22 22@2x
  ln -sr 24 24@2x
  ln -sr 32 32@2x
  ln -sr scalable scalable@2x

  cd ${dest}
  gtk-update-icon-cache ${name}${theme}${color}
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -a|--all)
      all="true"
      ;;
    -black)
      theme="-black"
      ;;
    -blue)
      theme="-blue"
      ;;
    -brown)
      theme="-brown"
      ;;
    -green)
      theme="-green"
      ;;
    -grey)
      theme="-grey"
      ;;
    -orange)
      theme="-orange"
      ;;
    -pink)
      theme="-pink"
      ;;
    -red)
      theme="-red"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
  shift
done

install_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
  done
}

install_all() {
for theme in "${themes[@]-${THEME_VARIANTS[@]}}"; do
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
  done
done
}

if [[ "${all}" == 'true' ]]; then
  install_all
  else
  install_theme
fi
