{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_currency as (
        select distinct
            CURRENCY_FOR_ORDER as CURRENCY_CODE,
            CURRENCY_FOR_ORDER as CURRENCY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
        where CURRENCY_FOR_ORDER is not null
        
        union all
        
        select distinct
            CURRENCY as CURRENCY_CODE,
            CURRENCY as CURRENCY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
        where CURRENCY is not null
        
        union all
        
        select distinct
            CURRENCY as CURRENCY_CODE,
            CURRENCY as CURRENCY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_payments") }}
        where CURRENCY is not null
    )

select * from intr_dim_currency