{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_payments as (
        select
            -- Dimension keys (will be replaced with actual IDs in mart layer)
            COMPANY,
            SUPPLIER_ID,
            CURRENCY,
            
            -- Measures
            PAYMENT_AMOUNT,
            INVOICES_PAID_COUNT,
            
            -- Attributes
            SUPPLIER,
            PAYMENT_DATE,
            PAYMENT_TYPE,
            RECORD_STATUS,
            SUPPLIER_REFERENCE,
            
            -- Audit columns
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_payments") }}
    )

select * from intr_fact_payments