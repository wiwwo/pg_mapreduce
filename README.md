# pg_mapreduce

## What

Distribute heavy loads on/to replicas in Postgresql, asyncronously, using DB Links.

## Why

Why not? :-D<br>
P.O.C. on dblinks ;-)<br>
Well, and more importantly, distributed *and asyncronous* tasks in PG


## How
Partition the big bad table in a way so that every replica (and the master, if you want/as in this case) has its own partition.
Let every replica do the operation on its own oart fo the data, as indicated in the `pgmapreduce.mapping` table.<br><br>
Of course, this does not make sense in docker, specially since it runs on the same (local) machine...<br>
But in a distributed env, and with millions or rows and some replicas, it gets more interesting.
<br><br>And of course, calculating the average is just a "whatever task". More useful things could be done.
<br><br>
IMPORTANT: use of this code in business context is strictly forbidden unless with explicit consent.

<br>

## Show me

### Init
```
$ ./stack_start.sh

$ psql -Uwiwwo -p5445  -hlocalhost postgres
Password for user wiwwo: wiwwo123

=# \i INIT.sql
(snip)
```

### Test run

#### Calling the Function

```
$ psql -Upgmapreduce -p5445  -hlocalhost postgres
Password for user pgmapreduce: pgmapreduce123

=> select pgmapreduce.calculate_avg();

```

#### More detailed version
```
$ psql -Upgmapreduce -p5445  -hlocalhost postgres
Password for user pgmapreduce: pgmapreduce123

=> select * from dblink.dblink_connect    ('dbl_pg_red',   'pg_red');
=> select * from dblink.dblink_connect    ('dbl_pg_green', 'pg_green');
=> select * from dblink.dblink_connect    ('dbl_pg_blue',  'pg_blue');

=> select * from dblink.dblink_send_query ('dbl_pg_red',   'select pgmapreduce.gimme_avg(''pg_red'')');
=> select * from dblink.dblink_send_query ('dbl_pg_green', 'select pgmapreduce.gimme_avg(''pg_green'')');
=> select * from dblink.dblink_send_query ('dbl_pg_blue',  'select pgmapreduce.gimme_avg(''pg_blue'')');

=> select * from dblink.dblink_get_result ('dbl_pg_red')   as avg_pg_red   (avg float);
=> select * from dblink.dblink_get_result ('dbl_pg_green') as avg_pg_green (avg float);
=> select * from dblink.dblink_get_result ('dbl_pg_blue')  as avg_pg_blue  (avg float);

=> exit
```

#### Cleanup

```
$ ./cleanup.sh
```
<br>

## INSPIRED BY

[Parallel jobs in Postgres](https://chumaky.team/blog/postgres-parallel-jobs)

[ Script - PostgreSQL multiple async parallel execution in PL/pgSQL ](https://www.soportedba.com/2017/06/script-postgresql-multiple-async.html)
