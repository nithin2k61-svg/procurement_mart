{{ config(materialized="table", tags=["daily"]) }}

with
    fact_receipts as (
        select
            -- Dimension foreign keys
            coalesce(ds.dim_supplier_id, -1) as dim_supplier_id,
            coalesce(dc.dim_company_id, -1) as dim_company_id,
            coalesce(dcur.dim_currency_id, -1) as dim_currency_id,
            
            -- Measures
            a.TOTAL_AMOUNT,
            a.RECEIPT_ADJUSTMENTS_FOR_RECEIPT,
            
            -- Attributes
            a.RECEIPT,
            a.RECEIPT_DATE,
            a.RECEIPT_STATUS,
            a.PURCHASE_ORDERS,
            a.REQUISITION_NUMBER,
            a.REQUISITIONER,
            a.SUPPLIER,
            
            -- Audit columns
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_fact_receipts") }} a
        left join {{ ref("dim_supplier") }} ds on a.SUPPLIER = ds.SUPPLIER_NAME
        left join {{ ref("dim_company") }} dc on a.COMPANY = dc.COMPANY_CODE
        left join {{ ref("dim_currency") }} dcur on a.CURRENCY = dcur.CURRENCY_CODE
    )

select * from fact_receipts