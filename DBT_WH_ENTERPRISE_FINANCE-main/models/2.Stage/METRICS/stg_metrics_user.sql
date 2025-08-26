{{ config(materialized="table",tags=['METRICS']) }}
with stg_metrics_user as (
    select DISTINCT 
        METRIC_CATEGORY_OWNER as METRIC_USER_NAME
    from {{source('metric_mart_sources','SRC_METRIC_CATEGORY')}}

    UNION 

    select DISTINCT 
        METRIC_CATEGORY_APPROVER as METRIC_USER_NAME
    from {{source('metric_mart_sources','SRC_METRIC_CATEGORY')}}

)
select METRIC_USER_NAME,
concat({{ getSourceSystemID(var('var_metrics_sourcesystemid'))}},'_',METRIC_USER_NAME) as SRC_UNIQ_CD,
{{ getSourceSystemID(var('var_metrics_sourcesystemid'))}} as SOURCE_SYSTEM_ID,
0 as DEL_INDC,
getdate() as ROW_CRE_DT,
'ETL_ADMIN' as ROW_CRE_USR_ID,
getdate() as ROW_MOD_DT,
'ETL_ADMIN' as ROW_MOD_USR_ID
from stg_metrics_user