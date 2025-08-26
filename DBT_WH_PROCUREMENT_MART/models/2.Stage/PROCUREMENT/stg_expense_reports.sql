{{ config(materialized="table", tags=["daily"]) }}

with
    stg_expense_reports as (
        select
            COMPANY,
            EXPENSE_REPORT,
            EXPENSE_REPORT_NUMBER,
            EXPENSE_REPORT_DATE,
            EXPENSE_REPORT_STATUS,
            PAY_TO,
            PAYEE_TYPE,
            CURRENCY,
            TOTAL_AMOUNT,
            CREDIT_CARD_PAID,
            EXPENSE_PAYEE_PAID,
            MEMO,
            '4' as src_sys_id,
            concat(src_sys_id, '_', EXPENSE_REPORT) as src_uniq_cd,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_cre_dt,
            coalesce(ROW_CRE_USR_ID, 'SFAdmin') as row_cre_usr_id,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_mod_dt,
            coalesce(ROW_MOD_USR_ID, 'SFAdmin') as row_mod_usr_id
        from {{ source("procurement_sources", "EXPENSE_REPORTS") }}
        where EXPENSE_REPORT is not null
    )

select * from stg_expense_reports