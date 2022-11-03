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

# Checks supporting distros
checkDistro() {
    # Checking distro
    if [ -e /etc/centos-release ]; then
        DISTRO=`cat /etc/redhat-release | awk '{print $1,$4}'`
        RPM=1
    elif [ -e /etc/fedora-release ]; then
        DISTRO=`cat /etc/fedora-release | awk '{print ($1,$3~/^[0-9]/?$3:$4)}'`
        RPM=2
    elif [ -e /etc/os-release ]; then
        DISTRO=`lsb_release -d | awk -F"\t" '{print $2}'`
        RPM=0
        DEB=1
    else
        DISTRO="UNKNOWN"
        RPM=0
        DEB=0
    fi
}

# Init official repo
# ---------------------------------------------------\

instalDebian() {

    # keep your currently-installed version
    # yes N | dpkg --configure -a

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

# Update repos data
apt update

if [[ "$_Q" -eq "1" ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt -yq install dnsdist
else
    apt -y install dnsdist
fi

# Final
echo -e "Done!"
dnsdist --version

}

checkDistro

if [[ "${DEB}" -eq "1" ]]; then
    instalDebian
else
    echo -e "Not supported distro. Exit..."
    exit 1
fi