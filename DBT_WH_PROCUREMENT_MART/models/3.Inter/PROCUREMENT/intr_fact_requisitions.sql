{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_requisitions as (
        select
            -- Dimension keys (will be replaced with actual IDs in mart layer)
            COMPANY,
            SUPPLIER_ID,
            REQUESTED_BY as BUYER,
            CURRENCY_FOR_REPORTING_TRANSACTION as CURRENCY,
            
            -- Measures
            TOTAL_AMOUNT,
            
            -- Attributes
            REQUISITION_NUMBER,
            STATUS,
            SUPPLIER,
            REQUEST_DATE,
            COMPLETED,
            AWAITING_PERSONS,
            APPROVED_BY_WORKERS,
            PO_NUMBER,
            SPEND_CATEGORIES_FOR_REQUISITION,
            BUSINESS_DOCUMENT_INTERNAL_MEMO,
            
            -- Audit columns
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_requisitions") }}
    )

select * from intr_fact_requisitions