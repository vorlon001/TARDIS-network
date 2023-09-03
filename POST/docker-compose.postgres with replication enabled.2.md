# How to setup a Postgres replication with docker and docker-compose

## How to use
To run you will need docker and docker-compose installed, and run the command
`docker-compose up`
on a folder within this file named docker-compose.yml(attached in this Gist)

How the PGAudit is enable, you will see the queries log and in which database is running which query, this is the main purpose of this Gist, along with have a database with replication working out of the box

## To add user with just reading rights to access the database on slave replica
*I suppose that you are inside the directory with the docker-compose file*
run the commands:

1 - Access the master container(you read right the user added to master will be replicated to slave)

```docker-compose exec postgresql-master bash```


2 - Access the psql client

```psql -U postgres```


3 - Run the SQL commands, creating the user 'reading_user' and giving him permissions
```
CREATE USER reading_user WITH PASSWORD 'reading_pass';
GRANT CONNECT ON DATABASE my_database TO reading_user;
\connect my_database
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reading_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO reading_user;
GRANT USAGE ON SCHEMA public TO reading_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO reading_user;
```
I suggest restart all containers and possible connections

The docke-compose.yml was heavily based on https://github.com/bitnami/bitnami-docker-postgresql/blob/72183d5623eb92a9781637f6f395f13ee93c5836/docker-compose-replication.yml
thanks bitnami for this great work

Questions about the SQL script https://stackoverflow.com/questions/760210/how-do-you-create-a-read-only-user-in-postgresql