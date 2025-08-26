{{ config(materialized="table", tags=["monthly"]) }}

with
    intr_dim_product_type as (
        select distinct
            product,
            product_type,
            product_type_group,
            product_type_category,
            src_sys_id,
            src_sys_id || '_' || product as src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_producttype") }}
    )

select *
from intr_dim_product_type
