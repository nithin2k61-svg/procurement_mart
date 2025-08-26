{{ config(materialized="table",tags=['METRICS']) }}
with intr_metrics as (
select  
mc.METRIC_CATEGORY_ID,
me.METRIC_CODE,
me.METRIC_TITLE,
me.METRIC_DESCRIPTION,
me.METRIC_UNIT,
me.UNIT_DIVISOR,
me.METRIC_INCEPTION_DATE,
me.SOURCE_SYSTEM_ID,
me.SRC_UNIQ_CD,
me.DEL_INDC,
me.ROW_CRE_DT,
me.ROW_CRE_USR_ID,
me.ROW_MOD_DT,
me.ROW_MOD_USR_ID
from {{ref('stg_metrics')}} me
    inner join {{ref("metrics_category")}} mc
    on mc.src_uniq_cd = me.SRC_UNIQ_CD_METRIC_CATEGORY_CODE
)    
select * from intr_metrics