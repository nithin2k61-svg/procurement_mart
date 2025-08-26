{{ config(materialized="table", tags=["monthly"]) }}

with
    intr_dim_source_system as (
        select distinct
            sourcesystemid,
            sourcesystemname,
            src_sys_id,
            trim(src_sys_id) || '_' || trim(sourcesystemid) as src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_sourcesystem") }}
    )

select *
from intr_dim_source_system
