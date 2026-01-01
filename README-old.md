How to run Oracle Databases on Macs with Apple silicon CPUs
=

Dependencies:
- GIT
- Docker (Desktop)
- Some Database Client that supports Oracle (most JetBrains IDEs will do)
- Go (if you want to run the Go example)
- Java 17+ (if you want to run the Java example)

Recently, Oracle released the first version of an Oracle DB compatible with ARM64 architecture. This is good news to users of Macs with Apple silicon.
Only Oracle 19 was ported as of April 2024.

To run this, you have to follow some steps:

1. Clone the repository oracle/docker-images:  
https://github.com/oracle/docker-images

2. download the file "LINUX.ARM64_1919000_db_home.zip" from here:  
https://www.oracle.com/database/technologies/oracle19c-linux-arm64-downloads.html#license-lightbox

**Don’t extract the zip.**  
Instead, move it to this directory on the cloned repo: docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0

3. Go to docker-images/OracleDatabase/SingleInstance/dockerfiles

And now run:  
./buildContainerImage.sh -e -v 19.3.0 -t oracle-local

**Now, let’s bring it up!**
4. Create a Docker volume to hold the data, so it survives the container restart:
Run the initialization script in this project:  
./init.sh

5. Start the Oracle database:  
./start.sh  

**Attention:** The first time you run the container, it will take a long while to start. On a MacBook Air M4 it took over 10 minutes.  
The other times it will be much faster, just a few seconds.

6. Connect to Oracle as SYSDBA and play around.

7. Run "go run testOraDB.go" to test the connection from Go.

8. Run ./run_test_oradb.sh to test the connection from Java.

Have fun!
=

