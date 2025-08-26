{{ config(materialized="table", tags=["daily"]) }}

with
    companies_from_po as (
        select distinct
            COMPANY,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where COMPANY is not null
    ),
    
    companies_from_invoices as (
        select distinct
            COMPANY,
            '3' as src_sys_id
        from {{ ref("stg_supplier_invoices") }}
        where COMPANY is not null
    ),
    
    companies_from_expenses as (
        select distinct
            COMPANY,
            '4' as src_sys_id
        from {{ ref("stg_expense_reports") }}
        where COMPANY is not null
    ),
    
    all_companies as (
        select * from companies_from_po
        union
        select * from companies_from_invoices
        union
        select * from companies_from_expenses
    ),

    intr_dim_company as (
        select distinct
            COMPANY as COMPANY_CODE,
            COMPANY as COMPANY_NAME,
            src_sys_id,
            concat(src_sys_id, '_', COMPANY) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_companies
    )

select *
from intr_dim_company