{{ config(materialized="table", tags=["daily"]) }}

with
    fact_expense_reports as (
        select
            case when dc.dim_company_id is null then -1 else dc.dim_company_id end as dim_company_id,
            case when dd.dim_date_id is null then -1 else dd.dim_date_id end as dim_expense_report_date_id,
            
            er.EXPENSE_REPORT,
            er.EXPENSE_REPORT_NUMBER,
            er.EXPENSE_REPORT_DATE,
            er.EXPENSE_REPORT_STATUS,
            er.PAY_TO,
            er.PAYEE_TYPE,
            er.CURRENCY,
            
            coalesce(er.TOTAL_AMOUNT, 0.00) as TOTAL_AMOUNT,
            coalesce(er.CREDIT_CARD_PAID, 0.00) as CREDIT_CARD_PAID,
            coalesce(er.EXPENSE_PAYEE_PAID, 0.00) as EXPENSE_PAYEE_PAID,
            
            er.MEMO,
            
            er.src_sys_id,
            er.src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
            
        from {{ ref("stg_expense_reports") }} er
        left outer join {{ ref("dim_company") }} dc 
            on er.COMPANY = dc.COMPANY_CODE
        left outer join {{ ref("dim_date") }} dd 
            on er.EXPENSE_REPORT_DATE = dd.dateday
    )

select *
from fact_expense_reports