{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_exchrates as (
        select
            a.FILENAME,
	        a.YEARMONTH as datekey,
            monthdate.dimdatekey,
	        a.ACCOUNT_NAME,
            a.ACCOUNT_CODE,
            a.ROLLUP,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "exchrates") }} a
                left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
    )
select *
from stg_exchrates order by ACCOUNT_NAME, ACCOUNT_CODE, datekey