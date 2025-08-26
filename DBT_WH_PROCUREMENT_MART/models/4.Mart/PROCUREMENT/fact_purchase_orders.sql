{{ config(materialized="table", tags=["daily"]) }}

with
    fact_purchase_orders as (
        select
            -- Dimension foreign keys
            coalesce(ds.dim_supplier_id, -1) as dim_supplier_id,
            coalesce(dc.dim_company_id, -1) as dim_company_id,
            coalesce(dsc.dim_spend_category_id, -1) as dim_spend_category_id,
            coalesce(dcc.dim_cost_center_id, -1) as dim_cost_center_id,
            coalesce(dcur.dim_currency_id, -1) as dim_currency_id,
            coalesce(db.dim_buyer_id, -1) as dim_buyer_id,
            coalesce(dl.dim_location_id, -1) as dim_location_id,
            coalesce(dp.dim_project_id, -1) as dim_project_id,
            
            -- Measures
            a.TOTAL_PO_AMOUNT,
            a.EXTENDED_AMOUNT,
            a.INVOICED_PO_AMOUNT,
            a.TOTAL_REMAINING_PO_AMOUNT,
            a.TOTAL_QUANTITY_ORDERED,
            a.QUANTITY_RECEIVED,
            a.QUANTITY_INVOICED,
            a.TOTAL_REMAINING_QUANTITY,
            a.AMOUNT_RECEIVED,
            a.ACTUAL_AMOUNT_INVOICED,
            a.RECEIPT_QUANTITY_VARIANCE,
            a.RECEIPT_AMOUNT_VARIANCE,
            
            -- Attributes
            a.PO_NUMBER,
            a.LINE,
            a.LINE_DESCRIPTION,
            a.SUPPLIER,
            a.BUSINESS_UNIT,
            a.PURCHASE_ORDER_STATUS,
            a.RECEIVING_STATUS,
            a.DOCUMENT_DATE,
            a.COMPLETED,
            a.SERVICE_LINE_START_DATE,
            a.SERVICE_LINE_END_DATE,
            a.REQUISITION,
            a.REQUISITION_SUBMITTED_BY_PERSON,
            a.REQUESTED_BY,
            a.RELATED_BUSINESS_DOCUMENT_LINES,
            a.BUSINESS_DOCUMENT_INTERNAL_MEMO,
            a.MEMO,
            a.AFPO,
            
            -- Audit columns
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_fact_purchase_orders") }} a
        left join {{ ref("dim_supplier") }} ds on a.SUPPLIER_ID = ds.SUPPLIER_CODE
        left join {{ ref("dim_company") }} dc on a.COMPANY = dc.COMPANY_CODE
        left join {{ ref("dim_spend_category") }} dsc on a.SPEND_CATEGORY = dsc.SPEND_CATEGORY_CODE
        left join {{ ref("dim_cost_center") }} dcc on a.COST_CENTER = dcc.COST_CENTER_CODE
        left join {{ ref("dim_currency") }} dcur on a.CURRENCY_FOR_ORDER = dcur.CURRENCY_CODE
        left join {{ ref("dim_buyer") }} db on a.BUYER = db.BUYER_CODE
        left join {{ ref("dim_location") }} dl on a.LOCATION = dl.LOCATION_CODE
        left join {{ ref("dim_project") }} dp on a.PROJECT = dp.PROJECT_CODE
    )

select * from fact_purchase_orders