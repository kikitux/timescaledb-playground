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

# `lsb_release -c -s` should return the correct codename of your OS
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c -s)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update

apt-get install ${APTARGS} -y postgresql-12

#for stasite sink -> db
apt-get install ${APTARGS} -y python-psycopg2

# Add our PPA
add-apt-repository -y ppa:timescale/timescaledb-ppa
apt-get update ${APTARGS}

# To install for PG 12
apt-get install ${APTARGS} -y timescaledb-postgresql-12
timescaledb-tune --quiet --yes
systemctl restart postgresql

sudo -u postgres psql <<EOF
DROP DATABASE IF EXISTS tutorial ;
CREATE database tutorial;
ALTER database tutorial SET timescaledb.telemetry_level=off;
\c tutorial;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- create schema
CREATE SCHEMA gauges;

-- We start by creating a regular SQL table
CREATE TABLE gauges.metrics (
  time        TIMESTAMPTZ       NOT NULL,
  hostname    TEXT              NOT NULL,
  name        TEXT              NOT NULL,
  metric      DOUBLE PRECISION  NOT NULL
);

SELECT create_hypertable('gauges.metrics', 'time', 'hostname', 4);

CREATE INDEX ON gauges.metrics (time DESC, hostname)
  WHERE hostname IS NOT NULL;

CREATE INDEX ON gauges.metrics (time DESC, name)
  WHERE name IS NOT NULL;

EOF

# to make sure telemetry is off
systemctl restart postgresql

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
