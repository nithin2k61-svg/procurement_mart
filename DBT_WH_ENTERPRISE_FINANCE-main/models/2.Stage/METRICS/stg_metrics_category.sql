{{ config(materialized="table",tags=['METRICS']) }}
with stg_metrics_category as (
select DISTINCT
        METRIC_CATEGORY_CODE,
        METRIC_CATEGORY_DESCRIPTION,
        {{ getSourceSystemID(var('var_metrics_sourcesystemid')) }} as SOURCE_SYSTEM_ID,
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid'))}},'_',METRIC_CATEGORY_OWNER) as SRC_UNIQ_CD_METRIC_CATEGORY_OWNER,
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid'))}},'_',METRIC_CATEGORY_APPROVER) as SRC_UNIQ_CD_METRIC_CATEGORY_APPROVER,
        concat({{ getSourceSystemID(var('var_metrics_sourcesystemid'))}},'_',METRIC_CATEGORY_CODE) as SRC_UNIQ_CD,
        0 as DEL_INDC,
        getdate() as ROW_CRE_DT,
        'ETL_ADMIN' as ROW_CRE_USR_ID,
        getdate() as ROW_MOD_DT,
        'ETL_ADMIN' as ROW_MOD_USR_ID
        from {{source('metric_mart_sources','SRC_METRIC_CATEGORY')}} mc 
)    
select * from stg_metrics_category