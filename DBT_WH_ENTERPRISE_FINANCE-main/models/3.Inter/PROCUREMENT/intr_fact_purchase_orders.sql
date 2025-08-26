{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_purchase_orders as (
        select
            case when ds.dim_supplier_id is null then -1 else ds.dim_supplier_id end as dim_supplier_id,
            case when dc.dim_company_id is null then -1 else dc.dim_company_id end as dim_company_id,
            case when dsc.dim_spend_category_id is null then -1 else dsc.dim_spend_category_id end as dim_spend_category_id,
            case when dcc.dim_cost_center_id is null then -1 else dcc.dim_cost_center_id end as dim_cost_center_id,
            case when dcur.dim_currency_id is null then -1 else dcur.dim_currency_id end as dim_currency_id,
            case when db.dim_buyer_id is null then -1 else db.dim_buyer_id end as dim_buyer_id,
            case when dl.dim_location_id is null then -1 else dl.dim_location_id end as dim_location_id,
            case when dp.dim_project_id is null then -1 else dp.dim_project_id end as dim_project_id,
            case when dd_doc.dim_date_id is null then -1 else dd_doc.dim_date_id end as dim_document_date_id,
            case when dd_comp.dim_date_id is null then -1 else dd_comp.dim_date_id end as dim_completed_date_id,
            
            po.PO_NUMBER,
            po.LINE,
            po.LINE_DESCRIPTION,
            po.BUYER,
            po.COST_CENTER,
            po.BUSINESS_UNIT,
            po.LOCATION,
            po.PROJECT,
            po.CURRENCY_FOR_ORDER,
            po.PURCHASE_ORDER_STATUS,
            po.RECEIVING_STATUS,
            po.DOCUMENT_DATE,
            po.COMPLETED,
            po.SERVICE_LINE_START_DATE,
            po.SERVICE_LINE_END_DATE,
            
            coalesce(po.TOTAL_PO_AMOUNT, 0.00) as TOTAL_PO_AMOUNT,
            coalesce(po.EXTENDED_AMOUNT, 0.00) as EXTENDED_AMOUNT,
            coalesce(po.INVOICED_PO_AMOUNT, 0.00) as INVOICED_PO_AMOUNT,
            coalesce(po.TOTAL_REMAINING_PO_AMOUNT, 0.00) as TOTAL_REMAINING_PO_AMOUNT,
            coalesce(po.TOTAL_QUANTITY_ORDERED, 0) as TOTAL_QUANTITY_ORDERED,
            coalesce(po.QUANTITY_RECEIVED, 0.00) as QUANTITY_RECEIVED,
            coalesce(po.QUANTITY_INVOICED, 0.00) as QUANTITY_INVOICED,
            coalesce(po.TOTAL_REMAINING_QUANTITY, 0) as TOTAL_REMAINING_QUANTITY,
            coalesce(po.AMOUNT_RECEIVED, 0.00) as AMOUNT_RECEIVED,
            coalesce(po.ACTUAL_AMOUNT_INVOICED, 0.00) as ACTUAL_AMOUNT_INVOICED,
            coalesce(po.RECEIPT_QUANTITY_VARIANCE, 0.00) as RECEIPT_QUANTITY_VARIANCE,
            coalesce(po.RECEIPT_AMOUNT_VARIANCE, 0.00) as RECEIPT_AMOUNT_VARIANCE,
            
            po.REQUISITION,
            po.REQUISITION_SUBMITTED_BY_PERSON,
            po.REQUESTED_BY,
            po.RELATED_BUSINESS_DOCUMENT_LINES,
            po.BUSINESS_DOCUMENT_INTERNAL_MEMO,
            po.MEMO,
            po.AFPO,
            
            po.src_sys_id,
            po.src_uniq_cd,
            po.row_cre_dt,
            po.row_cre_usr_id,
            po.row_mod_dt,
            po.row_mod_usr_id
            
        from {{ ref("stg_purchase_orders") }} po
        left outer join {{ ref("intr_dim_supplier") }} ds 
            on po.SUPPLIER_ID = ds.SUPPLIER_ID
        left outer join {{ ref("intr_dim_company") }} dc 
            on po.COMPANY = dc.COMPANY_CODE
        left outer join {{ ref("intr_dim_spend_category") }} dsc 
            on po.SPEND_CATEGORY = dsc.SPEND_CATEGORY_CODE
        left outer join {{ ref("intr_dim_cost_center") }} dcc 
            on po.COST_CENTER = dcc.COST_CENTER_CODE
        left outer join {{ ref("intr_dim_currency") }} dcur 
            on po.CURRENCY_FOR_ORDER = dcur.CURRENCY_CODE
        left outer join {{ ref("intr_dim_buyer") }} db 
            on po.BUYER = db.BUYER_CODE
        left outer join {{ ref("intr_dim_location") }} dl 
            on po.LOCATION = dl.LOCATION_CODE
        left outer join {{ ref("intr_dim_project") }} dp 
            on po.PROJECT = dp.PROJECT_CODE
        left outer join {{ ref("dim_date") }} dd_doc 
            on po.DOCUMENT_DATE = dd_doc.dateday
        left outer join {{ ref("dim_date") }} dd_comp 
            on po.COMPLETED = dd_comp.dateday
    )

select *
from intr_fact_purchase_orders