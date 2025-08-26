{{ config(materialized='incremental', dist='src_uniq_cd',unique_key = 'src_uniq_cd',on_schema_change='sync_all_columns',tags=['METRICS'] )}} 
with metrics as (
select  
        {{source('metrics_sequences','METRIC_ID')}}.nextval as METRIC_ID,
		A.METRIC_CATEGORY_ID,
		A.METRIC_CODE,
		A.METRIC_TITLE,
		A.METRIC_DESCRIPTION,
		A.METRIC_UNIT,
		A.UNIT_DIVISOR,
		A.METRIC_INCEPTION_DATE,
		A.SOURCE_SYSTEM_ID,
		A.SRC_UNIQ_CD,
		A.DEL_INDC,
		A.ROW_CRE_DT,
		A.ROW_CRE_USR_ID,
		A.ROW_MOD_DT,
		A.ROW_MOD_USR_ID
from {{ref('intr_metrics')}} A
{% if is_incremental() %} 
left outer join {{ this }} B on (A.SRC_UNIQ_CD = B.SRC_UNIQ_CD) 
where B.SRC_UNIQ_CD is null

 UNION ALL 
 
select  
		B.METRIC_ID,
		A.METRIC_CATEGORY_ID,
		A.METRIC_CODE,
		A.METRIC_TITLE,
		A.METRIC_DESCRIPTION,
		A.METRIC_UNIT,
		A.UNIT_DIVISOR,
		A.METRIC_INCEPTION_DATE,
		A.SOURCE_SYSTEM_ID,
		A.SRC_UNIQ_CD,
		A.DEL_INDC,
		B.ROW_CRE_DT,
		B.ROW_CRE_USR_ID,
		A.ROW_MOD_DT,
		A.ROW_MOD_USR_ID
from {{ref('intr_metrics')}} A
left outer join {{ this }} B on (A.SRC_UNIQ_CD = B.SRC_UNIQ_CD) 
where B.SRC_UNIQ_CD is not null 
{% endif %} 
 
)    
select * from metrics