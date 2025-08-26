{{ config(materialized="table", tags=["daily"]) }}

with
    stg_supplier_invoices as (
        select
            COMPANY,
            SUPPLIER_INVOICE,
            SUPPLIER_S_INVOICE_NUMBER,
            INVOICE_NUMBER,
            CF_LRV_SUPPLIER_ID,
            SUPPLIER,
            STATUS,
            INVOICE_DATE,
            DUE_DATE,
            CANCEL_DATE,
            DISCOUNT_DATE,
            CURRENCY,
            INVOICE_AMOUNT,
            BALANCE_DUE,
            PURCHASE_ORDERS,
            EXTERNAL_PO_NUMBER,
            SUPPLIER_INVOICE_SOURCE,
            PROCUREMENT_RELATED,
            INTERCOMPANY,
            DIRECT_INTERCOMPANY,
            DOWN_PAYMENT_INVOICE,
            TAX_ONLY,
            ON_HOLD,
            ADJUSTMENT,
            ADJUSTMENT_REASON,
            MEMO,
            '3' as src_sys_id,
            concat(src_sys_id, '_', SUPPLIER_INVOICE) as src_uniq_cd,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_cre_dt,
            coalesce(ROW_CRE_USR_ID, 'SFAdmin') as row_cre_usr_id,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_mod_dt,
            coalesce(ROW_MOD_USR_ID, 'SFAdmin') as row_mod_usr_id
        from {{ source("procurement_sources", "SUPPLIER_INVOICES") }}
        where SUPPLIER_INVOICE is not null
    )

select * from stg_supplier_invoices