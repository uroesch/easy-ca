#!/usr/bin/env bats

load functions

@test "Create root CA" {
  printf "%0.0s\n" {0..11} | \
    ${WORK_DIR}/create-root-ca -d ${ROOT_CA_DIR}
}

@test "Create signing CA" {
  printf "%0.0s\n" {0..11} | \
    ${ROOT_CA_DIR}/bin/create-signing-ca -d ${SIGNING_CA_DIR}
}

@test "Create server certificate '*.acme.com' with SAN 'acme.com'" {
  test::create-server --cn '*.acme.com' --san 'acme.com'
  test::verify-server 'star-acme-com.server.crt' {\*.,}acme.com
}

@test "Revoke server certficate '*.acme.com'" {
  test::revoke-cert 'star-acme-com.server.crt'
  test::verify-revokation 'star-acme-com.server.crt'
}

@test "Create SSL certificate 'ssl.acme.com' with SAN 'acme.com'" {
  test::create-ssl --cn 'ssl.acme.com' --san 'acme.com'
  test::verify-ssl 'ssl-acme-com.server.crt'
}

@test "Revoke server certficate 'ssl.acme.com'" {
  test::revoke-cert 'ssl-acme-com.server.crt'
  test::verify-revokation 'ssl-acme-com.server.crt'
}

@test "Create client certificate 'bobby@acme.com'" {
  test::create-client --cn 'bobby@acme.com'
}

@test "Revoke client certificate 'bobby@acme.com'" {
  test::revoke-cert 'bobby-acme-com.client.crt'
  test::verify-revokation 'bobby-acme-com.client.crt'
}

@test "Create client certificate 'bob@acme.com' with cert file 'bob_builder'" {
  test::create-client --cn 'bob@acme.com' --name 'bob_builder'
}

@test "Revoke client certificate 'bob@acme.com'" {
  test::revoke-cert 'bob-builder.client.crt'
  test::verify-revokation 'bob-builder.client.crt'
}

@test "Check usage messages" {
  test::usage \
    create-client \
    create-root-ca \
    create-server \
    create-signing-ca \
    create-ssl \
    revoke-cert
}

@test "Cleanup temporary directories" {
  test::cleanup
}
