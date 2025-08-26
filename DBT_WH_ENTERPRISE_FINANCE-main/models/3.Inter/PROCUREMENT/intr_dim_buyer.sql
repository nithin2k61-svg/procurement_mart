{{ config(materialized="table", tags=["daily"]) }}

with
    buyers_from_po as (
        select distinct
            BUYER,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where BUYER is not null
    ),
    
    all_buyers as (
        select * from buyers_from_po
    ),

    intr_dim_buyer as (
        select distinct
            BUYER as BUYER_CODE,
            BUYER as BUYER_NAME,
            -- Extract department from buyer name if follows pattern
            case 
                when upper(BUYER) like '%IT%' or upper(BUYER) like '%TECH%' then 'Information Technology'
                when upper(BUYER) like '%HR%' or upper(BUYER) like '%HUMAN%' then 'Human Resources'
                when upper(BUYER) like '%FIN%' or upper(BUYER) like '%FINANCE%' then 'Finance'
                when upper(BUYER) like '%PROC%' or upper(BUYER) like '%PURCH%' then 'Procurement'
                when upper(BUYER) like '%OPS%' or upper(BUYER) like '%OPERATION%' then 'Operations'
                else 'General'
            end as BUYER_DEPARTMENT,
            src_sys_id,
            concat(src_sys_id, '_', BUYER) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_buyers
    )

select *
from intr_dim_buyer