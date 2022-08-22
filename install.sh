#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Dnsdist installer for Debian-based distros

set -e

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Functions
# ---------------------------------------------------\

# Help information
usage() {

    echo -e "\nArguments:
    -q (use unattended installation with default DPKG config)"
    exit 1

}

# Checks arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -q|--quiet) _Q=1; ;;
        -h|--help) usage ;; 
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Init official repo
# ---------------------------------------------------\

# keep your currently-installed version
# yes N | dpkg --configure -a

install_repos() {
    # Install key
    apt update; apt -y install gnupg
    curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo apt-key add -

    # Install repos
cat > /etc/apt/sources.list.d/pdns.list <<_EOF_
deb [arch=amd64] http://repo.powerdns.com/debian bullseye-dnsdist-17 main
_EOF_

cat > /etc/apt/preferences.d/dnsdist <<_EOF_
Package: dnsdist*
Pin: origin repo.powerdns.com
Pin-Priority: 600
_EOF_
}

install_dnsdist() {
    # General install
    install_repos
    apt update
    apt -y install dnsdist
}

install_dnsdist_quiet() {
    install_repos
    export DEBIAN_FRONTEND=noninteractive
    apt-get -yq installdnsdist
}


final() {
    # Final
    echo -e "Done!"
    dnsdist --version
}

if [[ "$_Q" -eq "1" ]]; then
    install_dnsdist_quiet
else
    install_dnsdist
fi