{{ config(materialized="table", tags=["daily"]) }}

with
    fact_receipts as (
        select
            dim_company_id,
            dim_receipt_date_id,
            dim_currency_id,
            
            RECEIPT,
            RECEIPT_DATE,
            RECEIPT_STATUS,
            PURCHASE_ORDERS,
            REQUISITION_NUMBER,
            REQUISITIONER,
            SUPPLIER,
            
            TOTAL_AMOUNT,
            
            RECEIPT_ADJUSTMENTS_FOR_RECEIPT,
            
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("intr_fact_receipts") }}
    )

select *
from fact_receipts