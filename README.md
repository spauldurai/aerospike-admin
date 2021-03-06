# Aerospike Admin
## Description
Aerospike Admin provides an interface for Aerospike users to view the stat
of their Aerospike Cluster by fetching information from running cluster (Cluster mode) or logs (Log-analyser mode).
Start the tool with *asadm* and run the *help* command to get started.

## Installing Aerospike Admin

### Build Dependencies

- pip >= 9.0.3
- pex == 1.6.1
- requests == 2.18.4

### Install asadm as PEX
```
sudo make
sudo make install
```

### Install asadm without PEX
```
sudo pip install -r requirements.txt
sudo make no_pex
sudo make install
```

## Running Aerospike Admin in Live Cluster Mode.
asadm -h <Aerospike Server Address\>
Admin> help

## Running Aerospike Admin in Log-analyser Mode.
asadm -l [-f <location of logs\>]
Admin> help

## Running Aerospike Admin in Collectinfo Mode.
asadm -c [-f <location of collectinfo\>]
Admin> help


## Dependencies
- python 2.7+ (< 3)

### Python Modules
- bcrypt == 3.1.4
- cryptography >= 2.4.2
- jsonschema >= 2.5.1
- pexpect: >= 3.0
- ply: >= 3.4
- pyOpenSSL: >= 18.0.0
- pyasn1: >= 0.3.1
- toml


### Mac OSX
Run following command to ensure asadm history works properly:
```
sudo easy_install -a readline
```

## Tests
### Dependencies
- unittest2: 0.5.1
- Mock: 1.0.1

### Running Tests
./run_tests.sh or unit2 discover

## Profiling
### Dependencies
- yappi: 0.92

### Run Profiler
asadm --profile
Do not exit with 'ctrl+c' exit with the *exit* command
