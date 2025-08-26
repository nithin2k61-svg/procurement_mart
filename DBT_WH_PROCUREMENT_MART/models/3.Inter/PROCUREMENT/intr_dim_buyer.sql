{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_buyer as (
        select distinct
            BUYER as BUYER_CODE,
            BUYER as BUYER_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
        where BUYER is not null
        
        union all
        
        select distinct
            BUYER as BUYER_CODE,
            BUYER as BUYER_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
        where BUYER is not null
        
        union all
        
        select distinct
            BUYER as BUYER_CODE,
            BUYER as BUYER_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_requisitions") }}
        where BUYER is not null
    )

select * from intr_dim_buyer