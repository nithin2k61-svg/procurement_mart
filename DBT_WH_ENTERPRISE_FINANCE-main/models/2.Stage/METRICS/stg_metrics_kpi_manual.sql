{{ config(materialized="table",tags=['METRICS']) }}
with stg_metrics_kpi_manual as (
select
        k.METRIC_KPI_SNAP_DT,
        to_varchar(METRIC_KPI_SNAP_DT,'YYYYMMDD') src_uniq_cd_METRIC_KPI_SNAP_DT_ID,
        k.METRIC_CODE,
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid')) }},'_',k.METRIC_CODE) as src_uniq_cd_METRIC_ID,                      
        concat('7','_',k.PRODUCT_TYPE) as src_uniq_cd_PRODUCT_TYPE_ID,     
        concat('7','_',k.BUSINESS_UNIT_ID) as src_uniq_cd_BUSINESS_UNIT_ID,
        k.METRIC_DATE,
        to_varchar(k.METRIC_DATE,'YYYYMMDD') src_uniq_cd_METRIC_DATE_ID,
        CASE WHEN k.METRIC_CODE IN ('ARK_SPREAD','REVENUE_SHARE') THEN cast(k.KPI_VAL/m.UNIT_DIVISOR as number(38,1))
         ELSE cast(k.KPI_VAL/m.UNIT_DIVISOR as number(38,2))END as METRIC_KPI_VALUE,
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
    from {{source('metric_mart_sources','SRC_METRICS_KPI')}} k
    inner join {{source('metric_mart_sources','SRC_METRICS')}} m on k.METRIC_CODE = m.METRIC_CODE
)
select * from stg_metrics_kpi_manual
