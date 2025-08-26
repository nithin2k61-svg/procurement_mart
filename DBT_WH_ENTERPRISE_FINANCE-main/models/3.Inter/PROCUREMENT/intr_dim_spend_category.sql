{{ config(materialized="table", tags=["daily"]) }}

with
    spend_categories_from_po as (
        select distinct
            SPEND_CATEGORY,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where SPEND_CATEGORY is not null
    ),
    
    spend_categories_from_req as (
        select distinct
            SPEND_CATEGORIES_FOR_REQUISITION as SPEND_CATEGORY,
            '5' as src_sys_id
        from {{ ref("stg_requisitions") }}
        where SPEND_CATEGORIES_FOR_REQUISITION is not null
    ),
    
    all_spend_categories as (
        select * from spend_categories_from_po
        union
        select * from spend_categories_from_req
    ),

    intr_dim_spend_category as (
        select distinct
            SPEND_CATEGORY as SPEND_CATEGORY_CODE,
            SPEND_CATEGORY as SPEND_CATEGORY_NAME,
            case 
                when upper(SPEND_CATEGORY) like '%IT%' or upper(SPEND_CATEGORY) like '%TECHNOLOGY%' then 'Information Technology'
                when upper(SPEND_CATEGORY) like '%MARKETING%' or upper(SPEND_CATEGORY) like '%ADVERTISING%' then 'Marketing & Advertising'
                when upper(SPEND_CATEGORY) like '%OFFICE%' or upper(SPEND_CATEGORY) like '%SUPPLIES%' then 'Office Supplies'
                when upper(SPEND_CATEGORY) like '%TRAVEL%' then 'Travel & Entertainment'
                when upper(SPEND_CATEGORY) like '%PROFESSIONAL%' or upper(SPEND_CATEGORY) like '%CONSULTING%' then 'Professional Services'
                else 'Other'
            end as SPEND_CATEGORY_GROUP,
            src_sys_id,
            concat(src_sys_id, '_', SPEND_CATEGORY) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_spend_categories
    )

select *
from intr_dim_spend_category