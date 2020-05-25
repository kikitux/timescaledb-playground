#!/usr/bin/env bash

#bash /vagrant/deps/docker.sh
#docker build -t statsite:latest /vagrant/deps/statsite/

mkdir -p /etc/dpkg/dpkg.cfg.d
cat >/etc/dpkg/dpkg.cfg.d/01_nodoc <<EOF
path-exclude /usr/share/doc/*
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
EOF

export DEBIAN_FRONTEND=noninteractive
export APTARGS="-qq -o=Dpkg::Use-Pty=0"

# install deps
apt-get update ${APTARGS}
apt-get install ${APTARGS} -y build-essential check libtool automake autoconf gcc python python-requests scons pkg-config git

[ -d /vagrant/deps/statsite ] || {
  mkdir -p /vagrant/deps
  git clone https://github.com/statsite/statsite.git /vagrant/deps/statsite
}

pushd /vagrant/deps/statsite
./autogen.sh
./configure
make
make install
