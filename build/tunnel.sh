#!/bin/bash

RADDR=${remote_h}
RPORT=${remote_p}
LADDR=${local_h:-localhost}
LPORT=${local_p}
SSH_SERVER=${ssh_h}
SSH_USER=${ssh_u}
SSH_PORT=${ssh_p:-22}
USER=${tunnel_u}

#DEBUG="echo"
DEBUG=""

function usage() {
    echo usage: set following enviromental values and invoke tunnel.sh
    echo "  remote_h"
    echo "  remote_p"
    echo "  local_h"
    echo "  local_p"
    echo "  ssh_h"
    echo "  ssh_u"
    echo "  ssh_p"
    echo "  tunnel_u"
    echo "ex) "
    echo "  remote_h=10.1.1.1 report_p=8090 \\"
    echo "  local_h=localhost local_p=80 \\"
    echo "  ssh_h=10.1.1.1 ssh_u=nobody ssh_p=22 tunnel_u=nobody \\"
    echo "tunnel.sh"
}

function open_tunnel() {
    local _O=""; if [[ -n "${SSH_PORT}" ]]; then _O="-p ${SSH_PORT}"; fi
    local _S=""; if [[ -n "${USER}" ]]; then _S="sudo -u ${USER}"; fi
    local _R="${RPORT}"; if [[ -n "${RADDR}" ]]; then _R="${RADDR}:${RPORT}"; fi
    local _L="127.0.0.1"; if [[ -n "${LADDR}" ]]; then _L="${LADDR}"; fi
    $DEBUG ${_S} ssh ${_O} -N -R ${_R}:${_L}:${LPORT} ${SSH_USER}@${SSH_SERVER}
}

function close_tunnel() {
    L="$(ps auxww | \
         grep ssh | grep "$SSH_SERVER" | \
         grep "${SSH_USER}" | grep -e '-R' | \
         awk '{print $2}')"
    for p in l; do kill -9 $p; done
}

function health_tunnel() {
    local pt=$SSH_PORT
    if [[ -z $pt ]]; then pt=22; fi
    if [[ -z "$(ss -antp | grep ^ESTAB | grep ${SSH_SERVER} | grep $pt)" ]]; then
        echo 0  # unhealthy
    else
        echo 1  # healthy
    fi
}

# check vars
ERROR=""
if [[ -z "${RPORT}" ]];      then echo RPORT not defined; ERROR=1; fi
if [[ -z "${SSH_SERVER}" ]]; then echo SSH_SERVER not defined; ERROR=1; fi
if [[ -z "${SSH_USER}" ]];   then echo SSH_USER not defined; ERROR=1; fi
if [[ ${ERROR} == "1" ]]; then usage; exit 1; fi

# open tunnel with resilience
while true; do
    open_tunnel
    sleep 30
    close_tunnel
done

