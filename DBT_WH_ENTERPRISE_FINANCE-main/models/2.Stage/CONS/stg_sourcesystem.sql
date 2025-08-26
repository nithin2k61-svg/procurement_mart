{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_sourcesystem as (
        select
            sourcesystemid,
            sourcesystemname,
            '7' as src_sys_id,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("cons_sources", "ref_sourcesystem") }}
    )

select *
from stg_sourcesystem
