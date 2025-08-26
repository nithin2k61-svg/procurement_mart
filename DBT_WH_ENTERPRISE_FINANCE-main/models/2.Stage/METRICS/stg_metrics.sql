{{ config(materialized="table",tags=['METRICS']) }}
with stg_metrics as (
    select DISTINCT
        METRIC_CODE,
        METRIC_TITLE,
        METRIC_DESCRIPTION,
        METRIC_UNIT,
        UNIT_DIVISOR,
        METRIC_INCEPTION_DATE,
        {{ getSourceSystemID(var('var_metrics_sourcesystemid')) }} as SOURCE_SYSTEM_ID,
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid'))}},'_',METRIC_CODE) as SRC_UNIQ_CD,
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid'))}},'_',METRIC_CATEGORY_CODE) as SRC_UNIQ_CD_METRIC_CATEGORY_CODE,
        0 as DEL_INDC,
        getdate() as ROW_CRE_DT,
        'ETL_ADMIN' as ROW_CRE_USR_ID,
        getdate() as ROW_MOD_DT,
        'ETL_ADMIN' as ROW_MOD_USR_ID
    from {{source('metric_mart_sources','SRC_METRICS')}} m
)
select * from stg_metrics
