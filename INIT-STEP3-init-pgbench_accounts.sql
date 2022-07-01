\set QUIET 1

BEGIN;

drop table if exists public.pgbench_accounts;

CREATE TABLE public.pgbench_accounts
as
select generate_series::integer aid, generate_series::integer bid , round((random()*(10-1)+1)::numeric,2) abalance, null filler
from generate_series(1,9999)
;


---


drop table if exists public.pgbench_accounts_part;

CREATE TABLE public.pgbench_accounts_part (
    aid       integer NOT NULL,
    bid       integer,
    abalance  float,
    filler    character(84),
    part_key  smallint
)
partition by list (part_key);

create table public.pgbench_accounts_part_00 (like public.pgbench_accounts_part);
create table public.pgbench_accounts_part_01 (like public.pgbench_accounts_part);
create table public.pgbench_accounts_part_02 (like public.pgbench_accounts_part);

alter table public.pgbench_accounts_part attach partition public.pgbench_accounts_part_00 for values in (0);
alter table public.pgbench_accounts_part attach partition public.pgbench_accounts_part_01 for values in (1);
alter table public.pgbench_accounts_part attach partition public.pgbench_accounts_part_02 for values in (2);



insert into public.pgbench_accounts_part (aid, bid, abalance, filler, part_key)
select aid, bid, abalance, filler, aid % 3 as part_key from public.pgbench_accounts;


COMMIT;


\set QUIET 0


select avg(abalance) from public.pgbench_accounts_part;
