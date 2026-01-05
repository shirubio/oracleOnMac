# Running Oracle Database 19c on Apple Silicon Macs (Local Dev)

This guide explains how to run **Oracle Database 19c (ARM64)** locally
on **Apple Silicon Macs** using Docker.

This setup is intended for **local development only**: - No HA - No
backups - No hardening - Just a reproducible, reasonably realistic
Oracle DB for full-stack dev work

------------------------------------------------------------------------

## Prerequisites

You will need:

-   **Git**
-   **Docker Desktop** (Apple Silicon build, Docker Desktop 4.x+
    recommended)
-   **An Oracle-capable DB client**\
    (Most JetBrains IDEs work well)
-   **Java 17+** *(optional, for the Java example)*
-   **Go** *(optional, for the Go example)*

### System expectations

-   Apple Silicon Mac (M1/M2/M3/M4)
-   macOS 13+ recommended
-   \~20--30 GB free disk space
-   Be patient the first time 🙂

------------------------------------------------------------------------

## A note on Oracle + ARM64

As of **April 2024**, **Oracle Database 19c** is the only production
Oracle Database release officially available for **Linux ARM64**.

------------------------------------------------------------------------

## Step 1 -- Clone Oracle's Docker images repo

``` bash
git clone https://github.com/oracle/docker-images.git
```

------------------------------------------------------------------------

## Step 2 -- Download the Oracle 19c ARM64 binary

Download **LINUX.ARM64_1919000_db_home.zip** from Oracle and move it to:
``` text
docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/
```
https://www.oracle.com/database/technologies/oracle19c-linux-arm64-downloads.html#license-lightbox

**Do not unzip the file. Do not commit it.**

------------------------------------------------------------------------

## Step 2b (for X86 machines) -- Download the Oracle 19c x86-64 binary 

Download **LINUX.X64_193000_db_home.zip** from Oracle and move it to:
``` text
docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/
```
https://www.oracle.com/database/technologies/oracle19c-linux-downloads.html

**Do not unzip the file. Do not commit it.**

------------------------------------------------------------------------

## Step 3 -- Build the Docker image

``` bash
cd docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -e -v 19.3.0 -t oracle-local
```

------------------------------------------------------------------------

## Step 4 -- Initialize the database volume

``` bash
./init.sh
```

This deletes and recreates the `oracle-data` Docker volume.

------------------------------------------------------------------------

## Step 5 -- Start Oracle

``` bash
./start.sh
```

First startup can take 10+ minutes. Subsequent starts are fast.

------------------------------------------------------------------------

## Step 6 -- Connect to Oracle

Typical defaults: - Host: `localhost` - Port: `1521` - Service: your PDB
name - User: `SYS`, `SYSTEM`, or app user

------------------------------------------------------------------------

## Setup vs Startup scripts

### scripts/setup

-   Run once
-   Used for schema/user creation and seed data

### scripts/startup

-   Run every container start
-   Must be idempotent

Deleting the data volume triggers setup again.

------------------------------------------------------------------------

## Resetting everything

``` bash
./init.sh
./start.sh
```

------------------------------------------------------------------------

## Final notes

This setup is meant to be simple, reproducible, and safe to reset.
