{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_businessunit as (
        select
            businessunitid,
            businessunitname,
            '7' as src_sys_id,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("cons_sources", "ref_businessunit") }}
    )

select *
from stg_businessunit
