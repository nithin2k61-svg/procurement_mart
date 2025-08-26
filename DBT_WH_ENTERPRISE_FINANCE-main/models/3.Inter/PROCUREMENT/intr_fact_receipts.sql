{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_receipts as (
        select
            case when dc.dim_company_id is null then -1 else dc.dim_company_id end as dim_company_id,
            case when dd_rec.dim_date_id is null then -1 else dd_rec.dim_date_id end as dim_receipt_date_id,
            case when dcur.dim_currency_id is null then -1 else dcur.dim_currency_id end as dim_currency_id,
            
            rec.RECEIPT,
            rec.RECEIPT_DATE,
            rec.RECEIPT_STATUS,
            rec.PURCHASE_ORDERS,
            rec.REQUISITION_NUMBER,
            rec.REQUISITIONER,
            rec.SUPPLIER,
            
            coalesce(rec.TOTAL_AMOUNT, 0.00) as TOTAL_AMOUNT,
            
            rec.RECEIPT_ADJUSTMENTS_FOR_RECEIPT,
            
            rec.src_sys_id,
            rec.src_uniq_cd,
            rec.row_cre_dt,
            rec.row_cre_usr_id,
            rec.row_mod_dt,
            rec.row_mod_usr_id
            
        from {{ ref("stg_receipts") }} rec
        left outer join {{ ref("intr_dim_company") }} dc 
            on rec.COMPANY = dc.COMPANY_CODE
        left outer join {{ ref("dim_date") }} dd_rec 
            on rec.RECEIPT_DATE = dd_rec.dateday
        left outer join {{ ref("intr_dim_currency") }} dcur 
            on rec.CURRENCY = dcur.CURRENCY_CODE
    )

select *
from intr_fact_receipts