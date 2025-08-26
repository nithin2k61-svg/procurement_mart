{{ config(materialized="table", tags=["daily"]) }}

with
    fact_supplier_invoices as (
        select
            dim_supplier_id,
            dim_company_id,
            dim_invoice_date_id,
            dim_due_date_id,
            
            SUPPLIER_INVOICE,
            SUPPLIER_S_INVOICE_NUMBER,
            INVOICE_NUMBER,
            CF_LRV_SUPPLIER_ID,
            INVOICE_STATUS,
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
            
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("intr_fact_supplier_invoices") }}
    )

select *
from fact_supplier_invoices