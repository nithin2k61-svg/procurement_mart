{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_supplier_invoices as (
        select
            case when ds.dim_supplier_id is null then -1 else ds.dim_supplier_id end as dim_supplier_id,
            case when dc.dim_company_id is null then -1 else dc.dim_company_id end as dim_company_id,
            case when dd_inv.dim_date_id is null then -1 else dd_inv.dim_date_id end as dim_invoice_date_id,
            case when dd_due.dim_date_id is null then -1 else dd_due.dim_date_id end as dim_due_date_id,
            
            si.SUPPLIER_INVOICE,
            si.SUPPLIER_S_INVOICE_NUMBER,
            si.INVOICE_NUMBER,
            si.CF_LRV_SUPPLIER_ID,
            si.STATUS as INVOICE_STATUS,
            si.INVOICE_DATE,
            si.DUE_DATE,
            si.CANCEL_DATE,
            si.DISCOUNT_DATE,
            si.CURRENCY,
            
            coalesce(si.INVOICE_AMOUNT, 0.00) as INVOICE_AMOUNT,
            coalesce(si.BALANCE_DUE, 0.00) as BALANCE_DUE,
            
            si.PURCHASE_ORDERS,
            si.EXTERNAL_PO_NUMBER,
            si.SUPPLIER_INVOICE_SOURCE,
            si.PROCUREMENT_RELATED,
            si.INTERCOMPANY,
            si.DIRECT_INTERCOMPANY,
            si.DOWN_PAYMENT_INVOICE,
            si.TAX_ONLY,
            si.ON_HOLD,
            si.ADJUSTMENT,
            si.ADJUSTMENT_REASON,
            si.MEMO,
            
            si.src_sys_id,
            si.src_uniq_cd,
            si.row_cre_dt,
            si.row_cre_usr_id,
            si.row_mod_dt,
            si.row_mod_usr_id
            
        from {{ ref("stg_supplier_invoices") }} si
        left outer join {{ ref("intr_dim_supplier") }} ds 
            on si.CF_LRV_SUPPLIER_ID = ds.SUPPLIER_ID
        left outer join {{ ref("intr_dim_company") }} dc 
            on si.COMPANY = dc.COMPANY_CODE
        left outer join {{ ref("dim_date") }} dd_inv 
            on si.INVOICE_DATE = dd_inv.dateday
        left outer join {{ ref("dim_date") }} dd_due 
            on si.DUE_DATE = dd_due.dateday
    )

select *
from intr_fact_supplier_invoices