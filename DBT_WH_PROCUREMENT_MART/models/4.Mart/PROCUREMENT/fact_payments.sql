{{ config(materialized="table", tags=["daily"]) }}

with
    fact_payments as (
        select
            -- Dimension foreign keys
            coalesce(ds.dim_supplier_id, -1) as dim_supplier_id,
            coalesce(dc.dim_company_id, -1) as dim_company_id,
            coalesce(dcur.dim_currency_id, -1) as dim_currency_id,
            
            -- Measures
            a.PAYMENT_AMOUNT,
            a.INVOICES_PAID_COUNT,
            
            -- Attributes
            a.SUPPLIER,
            a.PAYMENT_DATE,
            a.PAYMENT_TYPE,
            a.RECORD_STATUS,
            a.SUPPLIER_REFERENCE,
            
            -- Audit columns
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_fact_payments") }} a
        left join {{ ref("dim_supplier") }} ds on a.SUPPLIER_ID = ds.SUPPLIER_CODE
        left join {{ ref("dim_company") }} dc on a.COMPANY = dc.COMPANY_CODE
        left join {{ ref("dim_currency") }} dcur on a.CURRENCY = dcur.CURRENCY_CODE
    )

select * from fact_payments