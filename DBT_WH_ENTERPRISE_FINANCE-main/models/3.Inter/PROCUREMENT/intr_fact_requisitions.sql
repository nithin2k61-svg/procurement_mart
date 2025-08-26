{{ config(materialized="table", tags=["daily"]) }}

with
    intr_fact_requisitions as (
        select
            case when ds.dim_supplier_id is null then -1 else ds.dim_supplier_id end as dim_supplier_id,
            case when dc.dim_company_id is null then -1 else dc.dim_company_id end as dim_company_id,
            case when dd_req.dim_date_id is null then -1 else dd_req.dim_date_id end as dim_request_date_id,
            case when dd_comp.dim_date_id is null then -1 else dd_comp.dim_date_id end as dim_completed_date_id,
            
            req.REQUISITION_NUMBER,
            req.STATUS as REQUISITION_STATUS,
            req.REQUEST_DATE,
            req.REQUESTED_BY,
            req.COMPLETED,
            req.AWAITING_PERSONS,
            req.APPROVED_BY_WORKERS,
            req.CURRENCY_FOR_REPORTING_TRANSACTION,
            
            coalesce(req.TOTAL_AMOUNT, 0.00) as TOTAL_AMOUNT,
            coalesce(req.PO_NUMBER, 0.00) as PO_NUMBER,
            
            req.SPEND_CATEGORIES_FOR_REQUISITION,
            req.BUSINESS_DOCUMENT_INTERNAL_MEMO,
            
            req.src_sys_id,
            req.src_uniq_cd,
            req.row_cre_dt,
            req.row_cre_usr_id,
            req.row_mod_dt,
            req.row_mod_usr_id
            
        from {{ ref("stg_requisitions") }} req
        left outer join {{ ref("intr_dim_supplier") }} ds 
            on req.SUPPLIER_ID = ds.SUPPLIER_ID
        left outer join {{ ref("intr_dim_company") }} dc 
            on req.COMPANY = dc.COMPANY_CODE
        left outer join {{ ref("dim_date") }} dd_req 
            on req.REQUEST_DATE = dd_req.dateday
        left outer join {{ ref("dim_date") }} dd_comp 
            on req.COMPLETED::date = dd_comp.dateday
    )

select *
from intr_fact_requisitions