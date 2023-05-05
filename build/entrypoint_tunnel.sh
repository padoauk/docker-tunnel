#!/bin/bash

#
# 1        2        3       4       5     6     7     8
# remote_h,remoet_p,local_h,local_p,ssh_h,ssh_u,ssh_p,tunnel_u
#

function r_h() {
    echo $(echo $* | awk -F, '{print $1}')
}
function r_p() {
    echo $(echo $* | awk -F, '{print $2}')
}
function l_h() {
    echo $(echo $* | awk -F, '{print $3}')
}
function l_p() {
    echo $(echo $* | awk -F, '{print $4}')
}
function s_h() {
    echo $(echo $* | awk -F, '{print $5}')
}
function s_u() {
    echo $(echo $* | awk -F, '{print $6}')
}
function s_p() {
    echo $(echo $* | awk -F, '{print $7}')
 }
function t_u() {
    echo $(echo $* | awk -F, '{print $8}')
}

#DEBUG="echo"
DEBUG=""

function open_tunnel(){
    local tn="$1"
    if [[ -n "${tn}" ]]; then
        export remote_h=$(r_h "${tn}")
        export remote_p=$(r_p "${tn}")
        export local_h=$(l_h "${tn}")
        export local_p=$(l_p "${tn}")
        export ssh_h=$(s_h "${tn}")
        export ssh_u=$(s_u "${tn}")
        export ssh_p=$(s_p "${tn}")
        export tunnel_u=$(t_u "${tn}")
        $DEBUG bash /tunnel.sh
    fi
}

if [[ -n "${TUNNEL}" ]]; then open_tunnel "${TUNNEL}" ; fi
if [[ -n "${TUNNEL_CONF}" ]]; then
    if [[ -f "${TUNNEL_CONF}" ]]; then
        while IFS= read -r line
        do
            echo line: $line
            # lines are comments if the initial letter is '#' or ' '.
            if [[ -n "$(echo $line | grep -v -e '^#' | grep -v -e '^ ' | grep -v -e '^$')" ]]; then
                ll=$(echo $line | sed 's/\s*,/,/g' | sed 's/,\s*/,/g') # remove spaces around ','
                open_tunnel "$ll" &
            fi
        done < "${TUNNEL_CONF}"
    else
        echo failed to read $TUNNEL_CONF
    fi
fi

    
exec "$@"

