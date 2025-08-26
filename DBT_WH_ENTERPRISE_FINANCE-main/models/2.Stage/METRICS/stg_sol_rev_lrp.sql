{{ config(materialized="table",tags=['METRICS']) }}
with stg_sol_rev_lrp as (
    select 
    DATE_TRUNC(Month,CURRENT_DATE)::DATE AS METRIC_KPI_SNAP_DT,
    to_varchar(METRIC_KPI_SNAP_DT,'YYYYMMDD') src_uniq_cd_METRIC_KPI_SNAP_DT_ID,
    'SOLUTIONS_REVENUE' AS METRIC_CODE, 
    -1 AS src_uniq_cd_METRIC_ID,                     
    -1 AS src_uniq_cd_PRODUCT_TYPE_ID,
    -- b.dim_business_unit_id as src_uniq_cd_BUSINESS_UNIT_ID,
    DATEADD(YEAR,+{{ var('var_metric_dateyear_sub_val')}},DATE_TRUNC(YEAR,CURRENT_DATE))::DATE AS  METRIC_DATE,         
    to_varchar(METRIC_DATE,'YYYYMMDD') src_uniq_cd_METRIC_DATE_ID,
    coalesce(sum(r.revenue_amount),0) as METRIC_KPI_VALUE,
    'na' METRIC_ANALYSIS_LEVEL1,
    'na' METRIC_ANALYSIS_LEVEL2,
    'na' METRIC_ANALYSIS_LEVEL3,	
    0 METRIC_OVERRIDE_INDC,
    -1 METRIC_OVERRIDE_USER_ID,
    {{ getSourceSystemID(var('var_metrics_sourcesystemid')) }} as SOURCE_SYSTEM_ID,
    {{ getSourceSystemID(var('var_metrics_sourcesystemid')) }} as SRC_SOURCE_SYSTEM_ID,
    concat(src_uniq_cd_METRIC_ID, '_', src_uniq_cd_METRIC_KPI_SNAP_DT_ID, '_', src_uniq_cd_METRIC_DATE_ID) as SRC_UNIQ_CD,
    -- -1 as SRC_UNIQ_CD,            
    0 as DEL_INDC,
    getdate() as row_cre_dt,
    'SF_Admin' as row_cre_usr_id,
    getdate() as row_mod_dt,
    'SF_Admin' as row_mod_usr_id
    
    from {{ ref('fact_lrp_revenue_aggr') }} r
    INNER JOIN  {{ ref('dim_date') }} d ON d.DIM_DATE_ID=R.dim_date_id
    INNER JOIN  {{ ref('dim_business_unit') }} b on b.BUSINESSUNITNAME = 'Payments'  

    WHERE DATEYEAR=2025
)
select * from stg_sol_rev_lrp
