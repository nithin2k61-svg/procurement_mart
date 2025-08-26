{{ config(materialized="table", tags=["daily"]) }}

with
    fact_requisitions as (
        select
            -- Dimension foreign keys
            coalesce(ds.dim_supplier_id, -1) as dim_supplier_id,
            coalesce(dc.dim_company_id, -1) as dim_company_id,
            coalesce(db.dim_buyer_id, -1) as dim_buyer_id,
            coalesce(dcur.dim_currency_id, -1) as dim_currency_id,
            
            -- Measures
            a.TOTAL_AMOUNT,
            
            -- Attributes
            a.REQUISITION_NUMBER,
            a.STATUS,
            a.SUPPLIER,
            a.REQUEST_DATE,
            a.COMPLETED,
            a.AWAITING_PERSONS,
            a.APPROVED_BY_WORKERS,
            a.PO_NUMBER,
            a.SPEND_CATEGORIES_FOR_REQUISITION,
            a.BUSINESS_DOCUMENT_INTERNAL_MEMO,
            
            -- Audit columns
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_fact_requisitions") }} a
        left join {{ ref("dim_supplier") }} ds on a.SUPPLIER_ID = ds.SUPPLIER_CODE
        left join {{ ref("dim_company") }} dc on a.COMPANY = dc.COMPANY_CODE
        left join {{ ref("dim_buyer") }} db on a.BUYER = db.BUYER_CODE
        left join {{ ref("dim_currency") }} dcur on a.CURRENCY = dcur.CURRENCY_CODE
    )

select * from fact_requisitions