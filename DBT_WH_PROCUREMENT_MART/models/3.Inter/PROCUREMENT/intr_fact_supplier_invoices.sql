{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_supplier_invoices as (
        select
            -- Dimension keys (will be replaced with actual IDs in mart layer)
            COMPANY,
            CF_LRV_SUPPLIER_ID as SUPPLIER_ID,
            CURRENCY,
            
            -- Measures
            INVOICE_AMOUNT,
            BALANCE_DUE,
            
            -- Attributes
            SUPPLIER_INVOICE,
            SUPPLIER_S_INVOICE_NUMBER,
            INVOICE_NUMBER,
            SUPPLIER,
            STATUS,
            INVOICE_DATE,
            DUE_DATE,
            CANCEL_DATE,
            DISCOUNT_DATE,
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
            
            -- Audit columns
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
    )

select * from intr_fact_supplier_invoices