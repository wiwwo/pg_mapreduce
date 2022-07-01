\set QUIET 1

begin;

create user pgmapreduce password 'pgmapreduce123';

drop schema if exists dblink CASCADE;
create schema dblink;

create extension dblink schema dblink;

create server pg_red   foreign data wrapper dblink_fdw options (host 'localhost', dbname 'postgres', port '5432');
create server pg_blue  foreign data wrapper dblink_fdw options (host 'pg_blue',   dbname 'postgres', port '5432');
create server pg_green foreign data wrapper dblink_fdw options (host 'pg_green',  dbname 'postgres', port '5432');

create user mapping for pgmapreduce server pg_red   options (user 'pgmapreduce', password 'pgmapreduce123');
create user mapping for pgmapreduce server pg_blue  options (user 'pgmapreduce', password 'pgmapreduce123');
create user mapping for pgmapreduce server pg_green options (user 'pgmapreduce', password 'pgmapreduce123');

grant usage on foreign server pg_red   to pgmapreduce;
grant usage on foreign server pg_blue  to pgmapreduce;
grant usage on foreign server pg_green to pgmapreduce;

grant usage on schema dblink to pgmapreduce;
grant execute on all functions in schema dblink to pgmapreduce;


grant usage on schema public to pgmapreduce;
grant select on all tables in schema public to pgmapreduce;
grant execute on all functions in schema dblink to pgmapreduce;

grant pg_read_all_data to pgmapreduce ;

commit;

\set QUIET 0
