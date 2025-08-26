{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_producttype as (
        select
            product,
            product_type,
            product_type_group,
            product_type_category,
            '7' as src_sys_id,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("cons_sources", "ref_producttype") }}
    )

select *
from stg_producttype
