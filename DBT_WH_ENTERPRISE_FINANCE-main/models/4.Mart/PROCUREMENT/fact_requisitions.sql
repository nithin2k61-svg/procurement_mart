{{ config(materialized="table", tags=["daily"]) }}

with
    fact_requisitions as (
        select
            dim_supplier_id,
            dim_company_id,
            dim_request_date_id,
            dim_completed_date_id,
            
            REQUISITION_NUMBER,
            REQUISITION_STATUS,
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
            
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("intr_fact_requisitions") }}
    )

select *
from fact_requisitions