{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_company as (
        select distinct
            COMPANY as COMPANY_CODE,
            COMPANY as COMPANY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
        where COMPANY is not null
        
        union all
        
        select distinct
            COMPANY as COMPANY_CODE,
            COMPANY as COMPANY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
        where COMPANY is not null
        
        union all
        
        select distinct
            COMPANY as COMPANY_CODE,
            COMPANY as COMPANY_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_requisitions") }}
        where COMPANY is not null
    )

select * from intr_dim_company