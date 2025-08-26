{{ config(materialized="table", tags=["daily"]) }}

with
    fact_supplier_invoices as (
        select
            -- Dimension foreign keys
            coalesce(ds.dim_supplier_id, -1) as dim_supplier_id,
            coalesce(dc.dim_company_id, -1) as dim_company_id,
            coalesce(dcur.dim_currency_id, -1) as dim_currency_id,
            
            -- Measures
            a.INVOICE_AMOUNT,
            a.BALANCE_DUE,
            
            -- Attributes
            a.SUPPLIER_INVOICE,
            a.SUPPLIER_S_INVOICE_NUMBER,
            a.INVOICE_NUMBER,
            a.SUPPLIER,
            a.STATUS,
            a.INVOICE_DATE,
            a.DUE_DATE,
            a.CANCEL_DATE,
            a.DISCOUNT_DATE,
            a.PURCHASE_ORDERS,
            a.EXTERNAL_PO_NUMBER,
            a.SUPPLIER_INVOICE_SOURCE,
            a.PROCUREMENT_RELATED,
            a.INTERCOMPANY,
            a.DIRECT_INTERCOMPANY,
            a.DOWN_PAYMENT_INVOICE,
            a.TAX_ONLY,
            a.ON_HOLD,
            a.ADJUSTMENT,
            a.ADJUSTMENT_REASON,
            a.MEMO,
            
            -- Audit columns
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_fact_supplier_invoices") }} a
        left join {{ ref("dim_supplier") }} ds on a.SUPPLIER_ID = ds.SUPPLIER_CODE
        left join {{ ref("dim_company") }} dc on a.COMPANY = dc.COMPANY_CODE
        left join {{ ref("dim_currency") }} dcur on a.CURRENCY = dcur.CURRENCY_CODE
    )

select * from fact_supplier_invoices