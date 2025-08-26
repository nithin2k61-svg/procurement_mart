{{ config(materialized="table",tags=['METRICS']) }}
with stg_curyear_stats_no_of_clients as (
    select
        DATE_TRUNC(Month,CURRENT_DATE)::DATE AS METRIC_KPI_SNAP_DT,
        to_varchar(METRIC_KPI_SNAP_DT,'YYYYMMDD') src_uniq_cd_METRIC_KPI_SNAP_DT_ID,
        'SOLUTIONS_REVENUE' AS METRIC_CODE, 
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid')) }},'_',METRIC_CODE) as src_uniq_cd_METRIC_ID,                      
        -1 AS src_uniq_cd_PRODUCT_TYPE_ID,
        -1 AS src_uniq_cd_BUSINESS_UNIT_ID,
        DATEADD(YEAR, -{{ var('var_metric_dateyear_sub_val')}},DATE_TRUNC(YEAR,CURRENT_DATE))::DATE AS  METRIC_DATE,          
        to_varchar(METRIC_DATE,'YYYYMMDD') as src_uniq_cd_METRIC_DATE_ID,
        coalesce(sum(r.NET_REVENUE_AMOUNT),0) as METRIC_KPI_VALUE,
        'na' METRIC_ANALYSIS_LEVEL1,
        'na' METRIC_ANALYSIS_LEVEL2,
        'na' METRIC_ANALYSIS_LEVEL3,
        0 METRIC_OVERRIDE_INDC,
        -1 METRIC_OVERRIDE_USER_ID,
        {{ getSourceSystemID(var('var_metrics_sourcesystemid')) }} as SOURCE_SYSTEM_ID,
        {{ getSourceSystemID(var('var_metrics_sourcesystemid')) }} as SRC_SOURCE_SYSTEM_ID,
        concat(src_uniq_cd_METRIC_ID, '_', src_uniq_cd_METRIC_KPI_SNAP_DT_ID, '_', src_uniq_cd_METRIC_DATE_ID) as SRC_UNIQ_CD,
        0 as DEL_INDC,
        getdate() as ROW_CRE_DT,
        'ETL_ADMIN' as ROW_CRE_USR_ID,
        getdate() as ROW_MOD_DT,
        'ETL_ADMIN' as ROW_MOD_USR_ID   
    from {{ ref('fact_revenue_aggr')}} r    
    INNER JOIN  {{ ref('dim_date') }} d ON d.DIM_DATE_ID=R.dim_date_id
    INNER JOIN  {{ ref('dim_business_unit') }} b on b.BUSINESSUNITNAME = 'Payments' 
    INNER JOIN {{ ref('dim_product_type')}} p on p.dim_product_type_id=r.dim_product_type_id
    WHERE 
    DATEYEAR=YEAR(GETDATE())
    GROUP BY 
    --r.dim_date_id,
    p.dim_product_type_id
)

select * from stg_curyear_stats_no_of_clients