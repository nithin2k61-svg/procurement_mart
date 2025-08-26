{{ config(materialized="table") }}

WITH stg_opex_aggr as (
    select 
    'unknown' as CLIENT_ID,
    product as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in('BU0001 Price Ops', 'BU0002 Price Indirect')  then '1'
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in ('BU0003 Payments Ops', 'BU0004 Payments Indirect')   then '2' 
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in ('BU0005 Network Analytics Ops', 'BU0006 Network Analytics Indirect', 'BU0008 Insights and Empowerment Ops', 'BU0009 Insights and Empowerment Indirect')  then '4' 
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in('BU0007 Corporate')  then '5' else -1 end as BUSINESS_UNIT_ID,
    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
    VENDOR as VENDOR,
   'ACTUALS' as TRAN_TYP,
    coalesce(sum(rollup),0) as OPEX_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','actuals_opex')}} a
     left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday
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
    VENDOR
union all

    select 
    'unknown' as CLIENT_ID,
    product as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in('BU0001 Price Ops', 'BU0002 Price Indirect')  then '1'
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in ('BU0003 Payments Ops', 'BU0004 Payments Indirect')   then '2' 
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in ('BU0005 Network Analytics Ops', 'BU0006 Network Analytics Indirect', 'BU0008 Insights and Empowerment Ops', 'BU0009 Insights and Empowerment Indirect')  then '4' 
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in('BU0007 Corporate')  then '5' else -1 end as BUSINESS_UNIT_ID,
    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
    VENDOR as VENDOR,
    'PLAN' as TRAN_TYP,
    coalesce(sum(rollup),0) as OPEX_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','plan_opex')}} a
        left outer join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday    
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
    VENDOR

union all

    select 
    'unknown' as CLIENT_ID,
    product as PRODUCT_TYPE_ID,
    6 as SRC_SYS_ID,
    case when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in('BU0001 Price Ops', 'BU0002 Price Indirect')  then '1'
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in ('BU0003 Payments Ops', 'BU0004 Payments Indirect')   then '2' 
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in ('BU0005 Network Analytics Ops', 'BU0006 Network Analytics Indirect', 'BU0008 Insights and Empowerment Ops', 'BU0009 Insights and Empowerment Indirect')  then '4' 
    when a.level_name = 'Zelis Consolidated (Rollup)' and a.business_unit in('BU0007 Corporate')  then '5' else -1 end as BUSINESS_UNIT_ID,
    'unknown' as PROVIDER_ID,
    yearmonth as DATEKEY,
    ACCOUNT_NAME as ACCOUNT_NAME,
    LEVEL_NAME as LEVEL_NAME,
    VENDOR as VENDOR,
    'FORECAST' as TRAN_TYP,
    coalesce(sum(rollup),0) as OPEX_AMOUNT,
    concat(src_sys_id, '_', CLIENT_ID) as srcuniqcd_dim_client,
    concat(src_sys_id, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    concat('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    concat('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    concat('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    from {{source('adaptive_comm_sources','forecast_opex')}} a
    left outer join
        {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.yearmonth, 'MONYYYY') = monthdate.dateday

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
    VENDOR
)
select * from stg_opex_aggr  order by  PRODUCT_TYPE_ID,BUSINESS_UNIT_ID,DATEKEY  

