#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Dnsdist installer for Debian-based distros

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Init official repo
# ---------------------------------------------------\

cat > /etc/apt/sources.list.d/pdns.list <<_EOF_
deb [arch=amd64] http://repo.powerdns.com/debian bullseye-dnsdist-17 main
_EOF_

cat > /etc/apt/preferences.d/dnsdist <<_EOF_
Package: dnsdist*
Pin: origin repo.powerdns.com
Pin-Priority: 600
_EOF_

apt update; apt install gnupg
curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo apt-key add -

# Install
apt update
apt -y install dnsdist

echo -e "Done!"
dnsdist --version

