{{ config(materialized="table",tags=['METRICS']) }}
with intr_metrics_user as (
select DISTINCT
      	METRIC_USER_NAME,
        SRC_UNIQ_CD,
		SOURCE_SYSTEM_ID,
		DEL_INDC,
		ROW_CRE_DT,
		ROW_CRE_USR_ID,
		ROW_MOD_DT,
		ROW_MOD_USR_ID
from {{ref('stg_metrics_user')}}
)    
select * from intr_metrics_user

