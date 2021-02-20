#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Globals
# -----------------------------------------------------------------------------
export WORK_DIR="${BATS_TEST_DIRNAME}/.."
export TEMP_DIR=${HOME}/tmp
export PREFIX_DIR=easy-ca-
export BASE_DIR=${TEMP_DIR}/${PREFIX_DIR}${PPID}
export ROOT_CA_DIR=${BASE_DIR}/root
export SIGNING_CA_DIR=${BASE_DIR}/signing

# used for setting the password for they CA keys
export CA_PASS=@T0pS3cr3t
export CA_PARENT_PASS=@T0pS3cr3t

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
function test::cleanup() {
  local dirs=$(find ${TEMP_DIR} -maxdepth 1 -type d -name "${PREFIX_DIR}*")
  for dir in ${dirs}; do
    echo "Removing directory '${dir}'"
    rm -rf ${dir}
  done
}

function test::dump-certificate() {
  local certificate=${1}; shift;
  openssl x509 \
    -noout \
    -text \
    -in ${SIGNING_CA_DIR}/certs/${certificate}
}

function test::fetch-serial() {
  local certificate=${1}; shift;
  openssl x509 \
    -noout \
    -serial \
    -in ${SIGNING_CA_DIR}/certs/${certificate} | \
    awk -F = '{print $2}'
}

function test::create-server() {
  printf "%0.0s\n" {0..6} | \
    ${SIGNING_CA_DIR}/bin/create-server "$@"
}

function test::verify-server() {
  local certificate=${1}; shift;
  local -a alternatives=( "$@" )
  for alt_name in "${alternatives[@]}"; do
    test::dump-certificate "${certificate}" | \
      grep -q "DNS:${alt_name}"
  done
}

function test::create-ssl() {
  printf "%0.0s\n" {0..6} | \
    ${SIGNING_CA_DIR}/bin/create-ssl "$@"
}

function test::verify-ssl() {
  local certificate=${1}; shift;
  test::dump-certificate "${certificate}" | \
    grep -q "Netscape Cert Type"
}

function test::create-client() {
  printf "%0.0s\n" {0..6} | \
    ${SIGNING_CA_DIR}/bin/create-client "$@"
}

function test::revoke-cert() {
  local certificate=${1}; shift;
  printf "1\ny\n" | \
    ${SIGNING_CA_DIR}/bin/revoke-cert \
    -C ${SIGNING_CA_DIR}/certs/${certificate}
}

function test::verify-revokation() {
  local certificate=${1}; shift;
  local serial=$(test::fetch-serial ${certificate})

  openssl crl \
    -noout \
    -text \
    -in ${SIGNING_CA_DIR}/crl/ca.crl | \
    grep -q "Serial Number: ${serial}"
}

function test::usage() {
  local -a scripts=( "$@" )
  for script in "${scripts[@]}"; do
    ${SIGNING_CA_DIR}/bin/${script} -h
  done
}
