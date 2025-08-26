{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_spend_category as (
        select distinct
            SPEND_CATEGORY as SPEND_CATEGORY_CODE,
            SPEND_CATEGORY as SPEND_CATEGORY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
        where SPEND_CATEGORY is not null
        
        union all
        
        select distinct
            SPEND_CATEGORY as SPEND_CATEGORY_CODE,
            SPEND_CATEGORY as SPEND_CATEGORY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
        where SPEND_CATEGORY is not null
        
        union all
        
        select distinct
            SPEND_CATEGORY as SPEND_CATEGORY_CODE,
            SPEND_CATEGORY as SPEND_CATEGORY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_requisitions") }}
        where SPEND_CATEGORY is not null
    )

select * from intr_dim_spend_category