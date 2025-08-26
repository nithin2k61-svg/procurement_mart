{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_purchase_orders as (
        select
            -- Dimension keys (will be replaced with actual IDs in mart layer)
            COMPANY,
            SUPPLIER_ID,
            BUYER,
            COST_CENTER,
            LOCATION,
            PROJECT,
            SPEND_CATEGORY,
            CURRENCY_FOR_ORDER,
            
            -- Measures
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
            
            -- Attributes
            PO_NUMBER,
            LINE,
            LINE_DESCRIPTION,
            SUPPLIER,
            BUSINESS_UNIT,
            PURCHASE_ORDER_STATUS,
            RECEIVING_STATUS,
            DOCUMENT_DATE,
            COMPLETED,
            SERVICE_LINE_START_DATE,
            SERVICE_LINE_END_DATE,
            REQUISITION,
            REQUISITION_SUBMITTED_BY_PERSON,
            REQUESTED_BY,
            RELATED_BUSINESS_DOCUMENT_LINES,
            BUSINESS_DOCUMENT_INTERNAL_MEMO,
            MEMO,
            AFPO,
            
            -- Audit columns
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
    )

select * from intr_fact_purchase_orders