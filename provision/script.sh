#!/usr/bin/env bash
set -e

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
apt-get install ${APTARGS} -y apt-transport-https ca-certificates curl software-properties-common vim git tmux htop
curl -s https://anonscm.debian.org/cgit/pkg-postgresql/postgresql-common.git/plain/pgdg/apt.postgresql.org.sh | bash
apt-get install ${APTARGS} -y postgresql-10

#for stasite sink -> db
apt-get install ${APTARGS} -y python-psycopg2

# Add our PPA
add-apt-repository -y ppa:timescale/timescaledb-ppa
apt-get update ${APTARGS}

# To install for PG 10
apt-get install ${APTARGS} -y timescaledb-postgresql-10
grep 'timescaledb' /etc/postgresql/10/main/postgresql.conf || {
  echo "shared_preload_libraries = 'timescaledb'" >> /etc/postgresql/10/main/postgresql.conf
  service postgresql restart
}

sudo -u postgres psql <<EOF
DROP DATABASE IF EXISTS tutorial ;
CREATE database tutorial;
\c tutorial;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- create schema
CREATE SCHEMA gauges;

-- We start by creating a regular SQL table
CREATE TABLE gauges.nproc (
  time        TIMESTAMPTZ       NOT NULL,
  hostname    TEXT              NOT NULL,
  nproc       DOUBLE PRECISION  NOT NULL
);

SELECT create_hypertable('gauges.nproc', 'time', 'hostname', 4);

CREATE INDEX ON gauges.nproc (time DESC, hostname)
  WHERE hostname IS NOT NULL;

EOF

sudo -u postgres psql <<EOF
DROP USER  IF EXISTS tutorial;
CREATE USER tutorial WITH PASSWORD 'tutorial';
GRANT ALL PRIVILEGES ON DATABASE "tutorial" to tutorial;
\c tutorial
GRANT  USAGE   ON SCHEMA gauges TO tutorial; 
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA gauges TO tutorial;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA gauges TO tutorial;
EOF

echo "done"
