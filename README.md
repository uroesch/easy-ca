[![Build](https://github.com/uroesch/easy-ca/workflows/verify-ca/badge.svg)](https://github.com/uroesch/easy-ca/actions?query=workflow%3Averify-ca)
[![Runs on](https://img.shields.io/badge/runs%20on-Linux%20%26%20macOS-blue)](#runtime-dependencies)
<!-- 
[![GitHub release (latest by date including 
pre-releases)](https://img.shields.io/github/v/release/uroesch/easy-ca?include_prereleases)](https://github.com/uroesch/easy-ca/releases)
![GitHub All Releases](https://img.shields.io/github/downloads/uroesch/easy-ca/total?style=flat) 
-->

# easy-ca
OpenSSL wrapper scripts for managing basic CA functions

A suite of bash scripts for automating very basic OpenSSL Certificate Authority 
operations:
* Creating Root CAs
* Creating Intermediate Signing CAs
* Creating Server certificates (with optional subjectAltNames)
* Creating Client certificates
* Revoking certificates and maintaining CRLs

## Compatibilty

The listed operating systems and bash version are automatically verified and 
tested at each pull request.

## Operating Systems

| Operating System                 | Compatible         |
| -------------------------------- | -----------------: |
| Ubuntu Xenial Xerus (16.04 LTS)  | :heavy_check_mark: |
| Ubuntu Bionic Beaver (18.04 LTS) | :heavy_check_mark: |
| Ubuntu Focal Fossa (18.04 LTS)   | :heavy_check_mark: |
| macOS Catalina 10.15             | :heavy_check_mark: |
| macOS Big Sur 11.0               | :heavy_check_mark: |

## Bash version

| Bash version | Compatible         |
| -----------: | -----------------: |
|        3.0.x | :heavy_check_mark: |
|        3.1.x | :heavy_check_mark: |
|        3.2.x | :heavy_check_mark: |
|        4.0.x | :heavy_check_mark: |
|        4.1.x | :heavy_check_mark: |
|        4.2.x | :heavy_check_mark: |
|        4.3.x | :heavy_check_mark: |
|        4.4.x | :heavy_check_mark: |
|        5.0.x | :heavy_check_mark: |
|        5.1.x | :heavy_check_mark: |

Earlier versions of Bash have not been tested but will most likely not work.

## Usage

### Create a new Root CA

The **create-root-ca** script will initialize a new Root CA directory 
structure. This script can be run directly from the source repo or from within 
an existing Easy CA installation. The CA is self-contained within the specified 
directory tree. It is portable and can be stored on removable media for 
security.

```bash
create-root-ca -d $ROOT_CA_DIR
```

**create-root-ca** will prompt for the basic DN configuration to use as 
defaults for this CA. Optionally, you can edit *defaults.conf* to set this 
information in advance. The new CA is now ready for use. The CA key, 
certificate, and CRL are available for review:

```bash
$ROOT_CA_DIR/ca/ca.crt
$ROOT_CA_DIR/private/ca.key
$ROOT_CA_DIR/crl/ca.crl
```


### (Optional) Create an Intermediate Signing CA

Running **create-signing-ca** from within a Root CA installation will 
initialize a new Intermediate CA directory structure, indepedent and separate 
from the Root CA. A Root CA may issue multiple Intermediate CAs.

```bash
$ROOT_CA_DIR/bin/create-signing-ca -d $SIGNING_CA_DIR
```

**create-signing-ca** will prompt for basic DN configuration, using the Root CA 
configuration as defaults. The Intermediate Signing CA is now ready for use. 
The CA key, certificate, chain file, and CRL are available for review:

```bash
$SIGNING_CA_DIR/ca/ca.crt
$SIGNING_CA_DIR/ca/chain.pem
$SIGNING_CA_DIR/private/ca.key
$SIGNING_CA_DIR/crl/ca.crl
```

## Using the Created Certificate Authority

After the Certificate Authority has been created, the scripts should be run on 
the created CA directory (At the first run the directory must no exist).
For example:

```bash
create-root-ca -d /opt/CA
cd /opt/CA/bin
create-client -c user1@bogus.com -n user1
```

### Issue a Server Certificate

Running **create-server** from within any CA installation will issue a new 
server (serverAuth) certificate:

```bash
$CA_DIR/bin/create-server -s fqdn.domain.com
```

Optionally, you can specify one (or more) subjectAltNames to accompany the new 
certificate:

```bash
$CA_DIR/bin/create-server -s fqdn.domain.com -a alt1.domain.com -a 
alt2.domain.com
```

**create-server** will prompt for basic DN configuration, using the CA 
configuration as defaults. After the script is completed, the server 
certificate, key, and CSR are available for review:

```bash
$CA_DIR/certs/fqdn-domain-com.server.crt
$CA_DIR/private/fqdn-domain-com.server.key
$CA_DIR/csr/fqdn-domain-com.server.csr
```

### Issue a Client Certificate

Running **create-client** from within any CA installation will issue a new 
client (clientAuth) certificate:

```bash
$CA_DIR/bin/create-client -c user@domain.com -n certname
```

**create-client** will prompt for basic DN configuration, using the CA 
configuration as defaults. After the script is completed, the client 
certificate, key, and CSR are available for review:

```bash
$CA_DIR/certs/user-domain-com.client.crt
$CA_DIR/private/user-domain-com.client.key
$CA_DIR/csr/user-domain-com.client.csr
```

```bash
$CA_DIR/bin/create-client -c user@domain.com
```

### Revoke a Certificate

Running **revoke-cert** from within a CA installation allows you to revoke a 
certificate issued by that CA and update the CRL:

For Server certificates:
```bash
$CA_DIR/bin/revoke-cert -c $CA_DIR/certs/fqdn-domain-com.server.crt
```

For Client certificates:
```bash
$CA_DIR/bin/revoke-cert -c $CA_DIR/certs/certificate.client.crt
```


**revoke-cert** will prompt for the revocation reason. After the script is 
completed, the server CRL is updated and available for review:

```bash
$CA_DIR/crl/ca.crl
```



## Caveats

These scripts are very simple, and make some hard-coded assumptions about 
behavior and configuration:
* Root and Intermediate CAs have a 3652-day lifetime
* Root and Intermediate CAs have 4096-bit RSA keys
* Root and Intermediate CA keys are always encrypted
* Only one level of Intermediate CA is supported
* Client and Server certificates have a 730-day lifetime
* Client and Server certificates have 4096-bit RSA keys and SHA512
* Client and Server keys are never encrypted
* There is no wrapper for renewing certificates
