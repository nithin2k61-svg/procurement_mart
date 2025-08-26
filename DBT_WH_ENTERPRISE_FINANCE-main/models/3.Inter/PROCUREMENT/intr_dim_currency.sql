{{ config(materialized="table", tags=["daily"]) }}

with
    currencies_from_po as (
        select distinct
            CURRENCY_FOR_ORDER as CURRENCY,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where CURRENCY_FOR_ORDER is not null
    ),
    
    currencies_from_invoices as (
        select distinct
            CURRENCY,
            '3' as src_sys_id
        from {{ ref("stg_supplier_invoices") }}
        where CURRENCY is not null
    ),
    
    currencies_from_expenses as (
        select distinct
            CURRENCY,
            '4' as src_sys_id
        from {{ ref("stg_expense_reports") }}
        where CURRENCY is not null
    ),
    
    currencies_from_receipts as (
        select distinct
            CURRENCY,
            '6' as src_sys_id
        from {{ ref("stg_receipts") }}
        where CURRENCY is not null
    ),
    
    currencies_from_payments as (
        select distinct
            CURRENCY,
            '7' as src_sys_id
        from {{ ref("stg_payments") }}
        where CURRENCY is not null
    ),
    
    all_currencies as (
        select * from currencies_from_po
        union
        select * from currencies_from_invoices
        union
        select * from currencies_from_expenses
        union
        select * from currencies_from_receipts
        union
        select * from currencies_from_payments
    ),

    intr_dim_currency as (
        select distinct
            CURRENCY as CURRENCY_CODE,
            case 
                when upper(CURRENCY) = 'USD' then 'US Dollar'
                when upper(CURRENCY) = 'EUR' then 'Euro'
                when upper(CURRENCY) = 'GBP' then 'British Pound'
                when upper(CURRENCY) = 'CAD' then 'Canadian Dollar'
                when upper(CURRENCY) = 'AUD' then 'Australian Dollar'
                when upper(CURRENCY) = 'JPY' then 'Japanese Yen'
                else CURRENCY
            end as CURRENCY_NAME,
            case 
                when upper(CURRENCY) in ('USD', 'EUR', 'GBP', 'JPY') then 'Major'
                else 'Other'
            end as CURRENCY_TYPE,
            src_sys_id,
            concat(src_sys_id, '_', CURRENCY) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_currencies
    )

select *
from intr_dim_currency