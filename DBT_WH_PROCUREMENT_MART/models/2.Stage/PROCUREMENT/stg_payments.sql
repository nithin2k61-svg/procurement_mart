{{ config(materialized="table", tags=["daily"]) }}

with
    stg_payments as (
        select
            COMPANY,
            SUPPLIER_ID,
            SUP as SUPPLIER,
            PMNT_DATE as PAYMENT_DATE,
            CURRENCY,
            PMT_AMT_REPT as PAYMENT_AMOUNT,
            PMT_TYPE as PAYMENT_TYPE,
            SUP_INVPAID as INVOICES_PAID_COUNT,
            REC_STATUS as RECORD_STATUS,
            SUP_83273646 as SUPPLIER_REFERENCE,
            '7' as src_sys_id,
            concat(src_sys_id, '_', SUPPLIER_ID, '_', PMNT_DATE, '_', PMT_AMT_REPT) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("procurement_sources", "SUPPLIER_PAYMENTS") }}
        where SUPPLIER_ID is not null
            and PMNT_DATE is not null
    )

select * from stg_payments