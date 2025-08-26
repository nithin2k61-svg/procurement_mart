{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_adaptive as (
            select
            a.client,
            case when a.product = 'PRD0043 Other Revenue' and a.BUSINESS_UNIT = 'BU0004 Payments Indirect' then concat(a.product, '-',a.BUSINESS_UNIT)
            when a.product in ('PRD0027 VCC', 'PRD0028 VCC Fax', 'PRD0029 VCC Print', 'PRD0030 VCC Download', 'PRD0031 VCC Other') and  a.REVENUE_GL_ACCOUNT in ('40000_Unsettled_', '40000_VolumeBased_Unsettled_') then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
            when a.product in ('PRD0032 ACH+', 'PRD0033 ACH+ (Provider-Sponsored)', 'PRD0035 VRA Card', 'PRD0036 VRA Card (Merchant Services)') and  a.REVENUE_GL_ACCOUNT in ('40000_Unsettled_', '40000_VolumeBased_Unsettled_') then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
            else a.product end as producttype,
            case when a.level_name = 'All Price - No Cost Center (Rollup)' then '1'
            when a.level_name = 'All Payments - No Cost Center (Rollup)' and producttype not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
            when a.level_name = 'All Payments - No Cost Center (Rollup)' and producttype in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
            when a.level_name = 'All Insights & Empowerment - No Cost Center (Rollup)' then '4' else -1 end as businessunit,
            a.yearmonth,
            monthdate.dateday as tranyearmonthdate,
            6 as src_sys_id,
            concat(src_sys_id, '_', a.client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            0 as volume_amount,
            0 as gross_revenue_amount,
            1 as realization_rate,
            coalesce(sum(rollup), 0) as net_revenue_amount
        from {{ source("adaptive_comm_sources", "actuals") }} a
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday

        where
            a.level_name in ('All Price - No Cost Center (Rollup)', 'All Payments - No Cost Center (Rollup)', 'All Insights & Empowerment - No Cost Center (Rollup)')
            and  a.REVENUE_GL_ACCOUNT NOT LIKE '%41600_%'
            and a.product <> 'PRD0001 No Product'
            and to_date(a.yearmonth, 'MONYYYY') < '{{ var('var_BUNAME_CUTOVERDATE') }}'
        group by
            a.client,
            producttype,
            businessunit,
            yearmonth,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            tranyearmonthdate,
            src_sys_id            
UNION ALL

select
            a.client,
            case when a.product = 'PRD0043 Other Revenue' and a.BUSINESS_UNIT = 'BU0004 Payments Indirect' then concat(a.product, '-',a.BUSINESS_UNIT)
            when a.product in ('PRD0027 VCC', 'PRD0028 VCC Fax', 'PRD0029 VCC Print', 'PRD0030 VCC Download', 'PRD0031 VCC Other') and  a.REVENUE_GL_ACCOUNT in ('40000_Unsettled_', '40000_VolumeBased_Unsettled_') then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
            when a.product in ('PRD0032 ACH+', 'PRD0033 ACH+ (Provider-Sponsored)', 'PRD0035 VRA Card', 'PRD0036 VRA Card (Merchant Services)') and  a.REVENUE_GL_ACCOUNT in ('40000_Unsettled_', '40000_VolumeBased_Unsettled_') then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
            else a.product end as producttype,
            case when a.level_name = 'All Price - No Cost Center (Rollup)' then '1'
            when a.level_name = 'All Payments - No Cost Center (Rollup)' and producttype not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
            when a.level_name = 'All Payments - No Cost Center (Rollup)' and producttype in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
            when a.level_name = 'All Insights & Empowerment - No Cost Center (Rollup)' then '4' else -1 end as businessunit,
            a.yearmonth,
            monthdate.dateday as tranyearmonthdate,
            6 as src_sys_id,
            concat(src_sys_id, '_', a.client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            0 as volume_amount,
            0 as gross_revenue_amount,
            1 as realization_rate,
            coalesce(sum(rollup), 0) as net_revenue_amount
        from {{ source("adaptive_comm_sources", "actuals") }} a
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday

        where
            a.level_name in ('All Price - No Cost Center (Rollup)', 'All Payments - No Cost Center (Rollup)', 'All Insights & Empowerment - No Cost Center (Rollup)')
            and  a.REVENUE_GL_ACCOUNT NOT LIKE '%41600_%'
            and a.product <> 'PRD0001 No Product'
            and to_date(a.yearmonth, 'MONYYYY') >= '{{ var('var_BUNAME_CUTOVERDATE') }}'
        group by
            a.client,
            producttype,
            businessunit,
            yearmonth,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            tranyearmonthdate,
            src_sys_id
    )
select *
from stg_revenue_adaptive order by client, producttype, businessunit, yearmonth
