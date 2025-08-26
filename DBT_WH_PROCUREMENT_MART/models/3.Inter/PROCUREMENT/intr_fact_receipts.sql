{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_receipts as (
        select
            -- Dimension keys (will be replaced with actual IDs in mart layer)
            COMPANY,
            SUPPLIER,
            CURRENCY,
            
            -- Measures
            TOTAL_AMOUNT,
            RECEIPT_ADJUSTMENTS_FOR_RECEIPT,
            
            -- Attributes
            RECEIPT,
            RECEIPT_DATE,
            RECEIPT_STATUS,
            PURCHASE_ORDERS,
            REQUISITION_NUMBER,
            REQUISITIONER,
            
            -- Audit columns
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_receipts") }}
    )

select * from intr_fact_receipts