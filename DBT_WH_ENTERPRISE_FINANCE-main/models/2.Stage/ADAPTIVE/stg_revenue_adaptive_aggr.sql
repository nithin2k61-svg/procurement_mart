{{ config(materialized="table") }}

WITH stg_revenue_adaptive_aggr as (
    select 
    client as CLIENT_ID,
    case when a.product = 'PRD0043 Other Revenue' and a.BUSINESS_UNIT = 'BU0004 Payments Indirect' then concat(a.product, '-',a.BUSINESS_UNIT)
    when a.product in ('PRD0027 VCC', 'PRD0028 VCC Fax', 'PRD0029 VCC Print', 'PRD0030 VCC Download', 'PRD0031 VCC Other') and a.REVENUE_GL_ACCOUNT = '40000_Unsettled_' then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
    when a.product in ('PRD0032 ACH+', 'PRD0033 ACH+ (Provider-Sponsored)', 'PRD0035 VRA Card', 'PRD0036 VRA Card (Merchant Services)') and a.REVENUE_GL_ACCOUNT = '40000_Unsettled_' then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
    else a.product end as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'All Price - No Cost Center (Rollup)' then '1'
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
    when a.level_name = 'All Insights & Empowerment - No Cost Center (Rollup)' then '4' 
    when a.level_name = 'All Corporate - No Cost Center (Rollup)' then '5' 
    else -1 end as BUSINESS_UNIT_ID,
    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
   'ACTUALS' as TRAN_TYP,
    a.REVENUE_GL_ACCOUNT REVENUE_GL_ACCOUNT,
    coalesce(sum(rollup),0) as REV_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','actuals')}} a
        left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
    where
    a.level_name in ('All Price - No Cost Center (Rollup)', 'All Insights & Empowerment - No Cost Center (Rollup)', 'All Payments - No Cost Center (Rollup)','Zelis Consolidated (Rollup)')
    and to_date(a.yearmonth, 'MONYYYY') < '{{ var('var_BUNAME_CUTOVERDATE') }}' 
    
    group by 
    CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME,
    REVENUE_GL_ACCOUNT

union all

    select 
    client as CLIENT_ID,
    case when a.product = 'PRD0043 Other Revenue' and a.BUSINESS_UNIT = 'BU0004 Payments Indirect' then concat(a.product, '-',a.BUSINESS_UNIT)
    when a.product in ('PRD0027 VCC', 'PRD0028 VCC Fax', 'PRD0029 VCC Print', 'PRD0030 VCC Download', 'PRD0031 VCC Other') and a.REVENUE_GL_ACCOUNT = '40000_Unsettled_' then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
    when a.product in ('PRD0032 ACH+', 'PRD0033 ACH+ (Provider-Sponsored)', 'PRD0035 VRA Card', 'PRD0036 VRA Card (Merchant Services)') and a.REVENUE_GL_ACCOUNT = '40000_Unsettled_' then concat(a.product, '-',a.REVENUE_GL_ACCOUNT)
    else a.product end as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'All Price - No Cost Center (Rollup)' then '1'
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
    when a.level_name = 'All Insights & Empowerment - No Cost Center (Rollup)' then '4' 
    when a.level_name = 'All Corporate - No Cost Center (Rollup)' then '5' else -1 end as BUSINESS_UNIT_ID,
    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
   'ACTUALS' as TRAN_TYP,
    a.REVENUE_GL_ACCOUNT REVENUE_GL_ACCOUNT,   
    coalesce(sum(rollup),0) as REV_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','actuals')}} a
        left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
    where
    a.level_name in ('Zelis Consolidated (Rollup)','All Price - No Cost Center (Rollup)', 'All Payments - No Cost Center (Rollup)', 'All Insights & Empowerment - No Cost Center (Rollup)', 'All Corporate - No Cost Center (Rollup)')
    and to_date(a.yearmonth, 'MONYYYY') >= '{{ var('var_BUNAME_CUTOVERDATE') }}'
    
    group by 
    CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME,
    REVENUE_GL_ACCOUNT

union all

    select 
    client as CLIENT_ID,
    product as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'All Price - No Cost Center (Rollup)' then '1'
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
    when a.level_name = 'All Insights & Empowerment - No Cost Center (Rollup)' then '4'
    when a.level_name = 'All Corporate - No Cost Center (Rollup)' then '5' else -1 end as BUSINESS_UNIT_ID,    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
    'PLAN' as TRAN_TYP,
    a.REVENUE_BY_CLIENT_GL REVENUE_GL_ACCOUNT, 
    coalesce(sum(rollup),0) as REV_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','plan_rev')}} a
        left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
    where a.level_name in ('Zelis Consolidated (Rollup)','All Price - No Cost Center (Rollup)', 'All Payments - No Cost Center (Rollup)', 'All Insights & Empowerment - No Cost Center (Rollup)', 'All Corporate - No Cost Center (Rollup)')

    group by 
    CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME,
    REVENUE_GL_ACCOUNT

union all

    select 
    client as CLIENT_ID,
    product as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'All Price - No Cost Center (Rollup)' then '1'
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
    when a.level_name = 'All Payments - No Cost Center (Rollup)' and PRODUCT_TYPE_ID in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
    when a.level_name = 'All Insights & Empowerment - No Cost Center (Rollup)' then '4'
    when a.level_name = 'All Corporate - No Cost Center (Rollup)' then '5' else -1 end as BUSINESS_UNIT_ID,    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
    'FORECAST' as TRAN_TYP,
    a.REVENUE_BY_CLIENT_GL REVENUE_GL_ACCOUNT,
    coalesce(sum(rollup),0) as REV_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','forecast_rev')}} a
    left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
    where a.level_name in ('Zelis Consolidated (Rollup)','All Price - No Cost Center (Rollup)', 'All Payments - No Cost Center (Rollup)', 'All Insights & Empowerment - No Cost Center (Rollup)', 'All Corporate - No Cost Center (Rollup)')

    group by 
    CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME,
    REVENUE_BY_CLIENT_GL
)
select * from stg_revenue_adaptive_aggr  order by  PRODUCT_TYPE_ID,BUSINESS_UNIT_ID,DATEKEY  

