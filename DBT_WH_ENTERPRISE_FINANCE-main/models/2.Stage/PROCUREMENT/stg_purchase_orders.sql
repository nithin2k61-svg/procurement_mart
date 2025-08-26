{{ config(materialized="table", tags=["daily"]) }}

with
    stg_purchase_orders as (
        select
            COMPANY,
            PO_NUMBER,
            LINE,
            LINE_DESCRIPTION,
            SUPPLIER_ID,
            SUPPLIER,
            BUYER,
            COST_CENTER,
            BUSINESS_UNIT,
            LOCATION,
            PROJECT,
            SPEND_CATEGORY,
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
            '2' as src_sys_id,
            concat(src_sys_id, '_', PO_NUMBER, '_', LINE) as src_uniq_cd,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_cre_dt,
            coalesce(ROW_CRE_USR_ID, 'SFAdmin') as row_cre_usr_id,
            coalesce(RAW_ROW_CRE_DT, getdate()) as row_mod_dt,
            coalesce(ROW_MOD_USR_ID, 'SFAdmin') as row_mod_usr_id
        from {{ source("procurement_sources", "CUSTOMIZED_PURCHASE_ORDERS") }}
        where PO_NUMBER is not null
    )

select * from stg_purchase_orders