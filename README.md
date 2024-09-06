How to run Oracle Databases on Macs with Apple silicon CPUs
=

Dependencies:
- GIT
- Docker (Desktop)
- Some Database Client that supports Oracle (most JetBrains IDEs will do)

Very recently, Oracle released the first version of an Oracle DB compatible with ARM64 architecture. This is good news to users of Macs with Apple silicon.
Only Oracle 19 was ported as of April 2024.

To run this you have to follow very simple steps:

1. Clone the repository oracle/docker-images:  
https://github.com/oracle/docker-images

2. download the file "LINUX.ARM64_1919000_db_home.zip" from here:  
https://www.oracle.com/database/technologies/oracle19c-linux-arm64-downloads.html#license-lightbox

**Don’t extract the zip.**  
Instead, move it to this directory on the cloned repo: docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0

3. Go to docker-images/OracleDatabase/SingleInstance/dockerfiles

And now run:  
./buildContainerImage.sh -e -v 19.3.0 -t oracle-local

Now, let’s bring it up!

4. Create a Docker volume to hold the data, so it survives the container restart:
docker volume create oracle-data       

5. Run the “docker-compose.yaml” file in this project: docker compose up -d  
**Attention:** The first time you run the container, it will take a long while to start. On a MacBook Air M3 with 24GB of RAM, it took about 10 minutes.  
The other times it will be much faster. A few seconds.

6. Connect to Oracle as SYSTEM and create a new user to play around. Look at the “create_user.sql” file in this project.
(Use 'create-user.sql' as an example)

7. Connect to the database using your favorite client. I use DataGrip, but you can use SQL Developer, SQLcl, or any other DB client.

Have fun!
=

