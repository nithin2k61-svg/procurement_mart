{{ config(materialized="table", tags=["daily"]) }}

with
    stg_receipts as (
        select
            COMPANY,
            RECEIPT,
            RECEIPT_DATE,
            RECEIPT_STATUS,
            PURCHASE_ORDERS,
            REQUISITION_NUMBER,
            REQUISITIONER,
            SUPPLIER,
            CURRENCY,
            TOTAL_AMOUNT,
            RECEIPT_ADJUSTMENTS_FOR_RECEIPT,
            '6' as src_sys_id,
            concat(src_sys_id, '_', RECEIPT) as src_uniq_cd,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_cre_dt,
            coalesce(ROW_CRE_USR_ID, 'SFAdmin') as row_cre_usr_id,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_mod_dt,
            coalesce(ROW_MOD_USR_ID, 'SFAdmin') as row_mod_usr_id
        from {{ source("procurement_sources", "RECEIPT_WITH_REQUISITIONER") }}
        where RECEIPT is not null
    )

select * from stg_receipts