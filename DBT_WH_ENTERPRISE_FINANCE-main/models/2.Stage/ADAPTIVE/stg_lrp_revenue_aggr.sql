{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_lrp_revenue_aggr as (
        select 
			-1 as client,
            a.product  as producttype,
            case when d.ATTRIBUTE_VALUE_LEVEL_TWO_NAME = 'All Price' then '1'
            when d.ATTRIBUTE_VALUE_LEVEL_TWO_NAME = 'All Payments' then '2'
            when d.ATTRIBUTE_VALUE_LEVEL_TWO_NAME = 'All Insights & Empowerment' then '4' else -1 end as businessunit,
            a.yearmonth,
            monthdate.dateday as tranyearmonthdate,
            '7' as src_sys_id,
            -1 as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            coalesce(sum(rollup), 0) as revenue_amount
         from {{source('adptive_sources','LRP_REVENUE')}} a
        inner join
            {{ source("adaptive_comm_sources", "dimensions") }} b
            on a.product = b.dimension_value_name
        inner join
            {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} c
            on b.attribute_id = c.attribute_id
            and b.attribute_value_id = c.product_id
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
        left outer join
            {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} d
            on a.business_unit = d.ATTRIBUTE_VALUE_LEVEL_ONE_NAME and d.ATTRIBUTE_NAME = 'Client_BU (WORKDAY)'
        where
           -- a.level_name in ('CCS (Rollup)', 'Sapphire (Rollup)', 'Payments (Rollup)') and
             b.attribute_name = 'Product_Hierarchy'
            and a.product <> 'PRD0001 No Product'
            --and to_date(a.yearmonth, 'MONYYYY') < '{{ var('var_BUNAME_CUTOVERDATE') }}' 
        group by
            producttype,
            businessunit,
            yearmonth,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            tranyearmonthdate,
            src_sys_id
    )
select *
from stg_lrp_revenue_aggr order by  producttype, businessunit, yearmonth
