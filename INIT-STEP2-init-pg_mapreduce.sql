\set QUIET 1

begin;

drop schema if exists pgmapreduce CASCADE;
create schema pgmapreduce;

create table pgmapreduce.mapping
(
server_name   text      not null,
part_key      smallint  not null
);

insert into pgmapreduce.mapping
(server_name, part_key)
values
 ('pg_red',   0)
,('pg_green', 1)
,('pg_blue',  2)
;

grant usage on schema public to pgmapreduce;
grant select on all tables in schema public to pgmapreduce;


CREATE OR REPLACE FUNCTION pgmapreduce.gimme_avg(in_server_name text)
   RETURNS numeric AS
$$
DECLARE
   retVal numeric;
BEGIN
   select avg(abalance)
    into retVal
    from pgbench_accounts_part pgb_a, pgmapreduce.mapping  mpr
    where mpr.server_name = in_server_name
      and mpr.part_key = pgb_a.part_key
    ;

   RETURN retVal;
END;
$$
language 'plpgsql';



CREATE OR REPLACE FUNCTION pgmapreduce.calculate_avg()
   RETURNS numeric
AS
$$
declare
   rec      record;
   result   text;

   idx      integer;

   arr_servers  text[];
   results      numeric[];

begin

   arr_servers[0] = 'pg_red';
   arr_servers[1] = 'pg_green';
   arr_servers[2] = 'pg_blue';

   -- raise info using message = concat('start: ', clock_timestamp());

   for i in 0..2 loop
      perform dblink.dblink_connect    ('job' || i::text, arr_servers[i]);
      perform dblink.dblink_send_query ('job' || i::text, 'select pgmapreduce.gimme_avg('''|| arr_servers[i] ||''')');
   end loop;

   while array_length(dblink.dblink_get_connections(), 1) > 0
   loop
      for rec in
         select unnest(dblink.dblink_get_connections()) val
      loop
         if dblink.dblink_is_busy(rec.val) = 0 then
            select t.res
              into result
              from dblink.dblink_get_result(rec.val) as t(res float)
            ;
            idx = substr(rec.val,4)::integer;
            results[idx] = result;
            -- raise info using message = '------- Result for '|| rec.val || ' is ' || results[idx];
            perform dblink.dblink_disconnect(rec.val);
         else
            -- raise info using message = 'Job ' || rec.val || ' is busy';
            null;
         end if;
      end loop;

      -- perform pg_sleep(1);
   end loop;

   -- raise info using message = concat('end: ', clock_timestamp());

   return (results[0]+results[1]+results[2])/3;
end;
$$
language 'plpgsql';

commit;

\set QUIET 0
