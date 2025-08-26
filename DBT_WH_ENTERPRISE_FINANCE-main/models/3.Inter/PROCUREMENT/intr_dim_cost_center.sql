{{ config(materialized="table", tags=["daily"]) }}

with
    cost_centers_from_po as (
        select distinct
            COST_CENTER,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where COST_CENTER is not null
    ),
    
    all_cost_centers as (
        select * from cost_centers_from_po
    ),

    intr_dim_cost_center as (
        select distinct
            COST_CENTER as COST_CENTER_CODE,
            COST_CENTER as COST_CENTER_NAME,
            case 
                when upper(COST_CENTER) like '%IT%' or upper(COST_CENTER) like '%TECH%' then 'Information Technology'
                when upper(COST_CENTER) like '%HR%' or upper(COST_CENTER) like '%HUMAN%' then 'Human Resources'
                when upper(COST_CENTER) like '%FIN%' or upper(COST_CENTER) like '%FINANCE%' then 'Finance'
                when upper(COST_CENTER) like '%SALES%' or upper(COST_CENTER) like '%MARKET%' then 'Sales & Marketing'
                when upper(COST_CENTER) like '%OPS%' or upper(COST_CENTER) like '%OPERATION%' then 'Operations'
                else 'Other'
            end as COST_CENTER_GROUP,
            src_sys_id,
            concat(src_sys_id, '_', COST_CENTER) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_cost_centers
    )

select *
from intr_dim_cost_center