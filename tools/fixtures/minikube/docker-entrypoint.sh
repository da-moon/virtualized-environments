#!/usr/bin/env bash
#!/usr/bin/env bash
# -*- mode: sh -*-
# vi: set ft=sh:tabstop=2:softtabstop=2:shiftwidth=2:expandtab
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export SLEEP_DURATION=0
COLUMNS=100
stty columns ${COLUMNS}


#
# ─── FUNCTION SECTION ───────────────────────────────────────────────────────────
#
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if [ -n "$(command -v apt-get)" ]; then
  export DEBIAN_FRONTEND=noninteractive
  echo >&2 "*** Detected Debian based Linux"
fi
if ! command -v "tput" >/dev/null ; then
  echo >&2  "*** 'tput' was not found in PATH"
  exit 1
fi
# [ NOTE ] => Bold
bold=$(tput bold)
# [ NOTE ] => Red Color
# red
red=$(tput setaf 1)
# [ NOTE ] => Green Color
green=$(tput setaf 2)
# [ NOTE ] => Yellow Color
yellow=$(tput setaf 3)
# [ NOTE ] => dark blue Color
dblue=$(tput setaf 4)
# [ NOTE ] => Reset color
reset=$(tput sgr0)
# printf-wrap
# Description:  Printf with smart word wrapping for every columns.
# Usage:        print-wrap "<text>" "<text>" ...
function printf-wrap () {
  local -r collen=$(($(tput cols)));
  local keyname="$1";
  local value=$2;
  while [ -n "$value" ] ; do
    printf >&2 "%-10s %-0s\n" "${keyname}" "${value:0:$collen}";
    keyname="";
    value=${value:$collen};
  done
}

function err() {
    local -r value=$1;
    local -r keyname="${bold}[   ${red}ERROR${reset}${bold}  ]${reset}"
    printf-wrap "${keyname}" "${value}"
}
function info() {
    local -r value=$1;
    local -r keyname="${bold}[   ${green}INFO${reset}${bold}   ]${reset}"
    printf-wrap "${keyname}" "${value}"
}

function warn() {
    local -r value=$1;
    local -r keyname="${bold}[  ${yellow}WARNING${reset}${bold} ]${reset}"
    printf-wrap "${keyname}" "${value}"
}

function section(){
  if [[ $# == 0 ]]; then
    err "this function needs arguments"
    exit 1
  fi
  local -r terminal_cols="$(tput cols)"
  while [[ $# -gt 0 ]]; do
    local key="$1"
    case "$key" in
      --message)
        local -r message="$2"
        echo >&2 ""
        info "${message}"
        echo >&2 ""
        shift
      ;;
      --params)
        local key="$2"
        shift
        local value="$2"
        shift
        key="[   ${bold}${key}${reset}   ] =>"
        value="${dblue}${value}${reset}"
        printf-wrap "${key}" "${value}"
      ;;
      --command)
        local command="$2"
        echo >&2 "${yellow}"
        printf "\n%${terminal_cols}s\n" | tr ' ' '-' >&2
        echo >&2 ""
        echo >&2 "  ${command}"
        echo >&2 ""
        printf "%${terminal_cols}s\n" | tr ' ' '-' >&2
        echo >&2 "${reset}"
        sleep "${SLEEP_DURATION}"
        bash -c "${command}"
        shift
      ;;
      *)
        err "unacceptable arg ${red}${key}${reset}"
        exit 1
      ;;
    esac
    shift
  done
  printf "\n%${terminal_cols}s\n" | tr ' ' '#' >&2
  sleep "${SLEEP_DURATION}"
  echo >&2 ""
}
#
# ──────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: S C R I P T   E X E C U T I O N   S T A R T : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────
#


#clean pid after unexpected kill
if [ -f "/var/run/docker.pid" ]; then
	rm -rf /var/run/docker.pid
fi

# reread all config
source /etc/profile

echo >&2 ""

message=$(cat <<EOF
${red}
─── KUBERNETES INIT ────────────────────────────────────────────────────────────
${reset}
EOF
)

echo >&2 "$message"

# message="ensuring minikube has started"
# command="minikube start || true"
# section --message "$message" --command "$command"

if [[ "$1" == 'minikube' ]]; then
    echo >&2 "***Starting minikube..."
    minikube start \
        --extra-config=apiserver.Audit.LogOptions.Path="/var/log/apiserver/audit.log" \
        --extra-config=apiserver.Audit.LogOptions.MaxAge=30 \
        --extra-config=apiserver.Audit.LogOptions.MaxSize=100 \
        --extra-config=apiserver.Audit.LogOptions.MaxBackups=5 \
        --bootstrapper=localkube \
        --vm-driver=docker

    echo "Setting kubeconfig context..."
    sudo minikube update-context

    echo "Waiting for minkube to be ready..."
    # this for loop waits until kubectl can access the api server that Minikube has created
    set +e
    j=0
    while [ $j -le 150 ]; do
        kubectl get po &> /dev/null
        if [ $? -ne 1 ]; then
            break
        fi
        sleep 2
        j=$(( j + 1 ))
    done
    set -e

    if [[ -d "/kube_specs" ]]; then
        echo "Apply kubernetes specs..."
        kubectl apply -R -f /kube_specs/
    fi

    echo "Minikube is ready."
    minikube logs -f
fi

exec "$@"