{{ config(materialized="table", tags=["daily"]) }}

with
    fact_expense_reports as (
        select
            -- Dimension foreign keys
            coalesce(dc.dim_company_id, -1) as dim_company_id,
            coalesce(dcur.dim_currency_id, -1) as dim_currency_id,
            
            -- Measures
            a.TOTAL_AMOUNT,
            
            -- Attributes
            a.EXPENSE_REPORT,
            a.STATUS,
            a.SUBMITTED_BY,
            a.SUBMITTED_DATE,
            a.APPROVED_BY,
            a.APPROVED_DATE,
            a.COMPLETED,
            a.BUSINESS_DOCUMENT_INTERNAL_MEMO,
            
            -- Audit columns
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("stg_expense_reports") }} a
        left join {{ ref("dim_company") }} dc on a.COMPANY = dc.COMPANY_CODE
        left join {{ ref("dim_currency") }} dcur on a.CURRENCY = dcur.CURRENCY_CODE
    )

select * from fact_expense_reports