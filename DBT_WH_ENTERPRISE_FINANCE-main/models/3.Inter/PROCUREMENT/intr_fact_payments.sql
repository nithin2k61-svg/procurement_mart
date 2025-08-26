{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_payments as (
        select
            case when ds.dim_supplier_id is null then -1 else ds.dim_supplier_id end as dim_supplier_id,
            case when dc.dim_company_id is null then -1 else dc.dim_company_id end as dim_company_id,
            case when dd_pay.dim_date_id is null then -1 else dd_pay.dim_date_id end as dim_payment_date_id,
            case when dcur.dim_currency_id is null then -1 else dcur.dim_currency_id end as dim_currency_id,
            
            pay.PAYMENT_DATE,
            pay.PAYMENT_TYPE,
            pay.RECORD_STATUS,
            pay.SUPPLIER_REFERENCE,
            
            coalesce(pay.PAYMENT_AMOUNT, 0.00) as PAYMENT_AMOUNT,
            coalesce(pay.INVOICES_PAID_COUNT, 0) as INVOICES_PAID_COUNT,
            
            pay.src_sys_id,
            pay.src_uniq_cd,
            pay.row_cre_dt,
            pay.row_cre_usr_id,
            pay.row_mod_dt,
            pay.row_mod_usr_id
            
        from {{ ref("stg_payments") }} pay
        left outer join {{ ref("intr_dim_supplier") }} ds 
            on pay.SUPPLIER_ID = ds.SUPPLIER_ID
        left outer join {{ ref("intr_dim_company") }} dc 
            on pay.COMPANY = dc.COMPANY_CODE
        left outer join {{ ref("dim_date") }} dd_pay 
            on pay.PAYMENT_DATE = dd_pay.dateday
        left outer join {{ ref("intr_dim_currency") }} dcur 
            on pay.CURRENCY = dcur.CURRENCY_CODE
    )

select *
from intr_fact_payments