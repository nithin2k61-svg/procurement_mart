{{ config(materialized="table", tags=["daily"]) }}

with
    fact_payments as (
        select
            dim_supplier_id,
            dim_company_id,
            dim_payment_date_id,
            dim_currency_id,
            
            PAYMENT_DATE,
            PAYMENT_TYPE,
            RECORD_STATUS,
            SUPPLIER_REFERENCE,
            
            PAYMENT_AMOUNT,
            INVOICES_PAID_COUNT,
            
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("intr_fact_payments") }}
    )

select *
from fact_payments