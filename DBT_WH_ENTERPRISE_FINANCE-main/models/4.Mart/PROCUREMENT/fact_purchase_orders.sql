{{ config(materialized="table", tags=["daily"]) }}

with
    fact_purchase_orders as (
        select
            dim_supplier_id,
            dim_company_id,
            dim_spend_category_id,
            dim_document_date_id,
            dim_completed_date_id,
            
            PO_NUMBER,
            LINE,
            LINE_DESCRIPTION,
            BUYER,
            COST_CENTER,
            BUSINESS_UNIT,
            LOCATION,
            PROJECT,
            CURRENCY_FOR_ORDER,
            PURCHASE_ORDER_STATUS,
            RECEIVING_STATUS,
            DOCUMENT_DATE,
            COMPLETED,
            SERVICE_LINE_START_DATE,
            SERVICE_LINE_END_DATE,
            
            TOTAL_PO_AMOUNT,
            EXTENDED_AMOUNT,
            INVOICED_PO_AMOUNT,
            TOTAL_REMAINING_PO_AMOUNT,
            TOTAL_QUANTITY_ORDERED,
            QUANTITY_RECEIVED,
            QUANTITY_INVOICED,
            TOTAL_REMAINING_QUANTITY,
            AMOUNT_RECEIVED,
            ACTUAL_AMOUNT_INVOICED,
            RECEIPT_QUANTITY_VARIANCE,
            RECEIPT_AMOUNT_VARIANCE,
            
            REQUISITION,
            REQUISITION_SUBMITTED_BY_PERSON,
            REQUESTED_BY,
            RELATED_BUSINESS_DOCUMENT_LINES,
            BUSINESS_DOCUMENT_INTERNAL_MEMO,
            MEMO,
            AFPO,
            
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("intr_fact_purchase_orders") }}
    )

select *
from fact_purchase_orders