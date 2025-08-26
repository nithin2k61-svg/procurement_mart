{{ config(materialized="table", tags=["daily"]) }}

with
    stg_requisitions as (
        select
            COMPANY,
            REQUISITION_NUMBER,
            STATUS,
            SUPPLIER_ID,
            SUPPLIER,
            REQUEST_DATE,
            REQUESTED_BY,
            COMPLETED,
            AWAITING_PERSONS,
            APPROVED_BY_WORKERS,
            CURRENCY_FOR_REPORTING_TRANSACTION,
            TOTAL_AMOUNT,
            PO_NUMBER,
            SPEND_CATEGORIES_FOR_REQUISITION,
            BUSINESS_DOCUMENT_INTERNAL_MEMO,
            '5' as src_sys_id,
            concat(src_sys_id, '_', REQUISITION_NUMBER) as src_uniq_cd,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_cre_dt,
            coalesce(ROW_CRE_USR_ID, 'SFAdmin') as row_cre_usr_id,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_mod_dt,
            coalesce(ROW_MOD_USR_ID, 'SFAdmin') as row_mod_usr_id
        from {{ source("procurement_sources", "REQUISITIONS_BY_COMPANY") }}
        where REQUISITION_NUMBER is not null
    )

select * from stg_requisitions