{{ config(materialized='table')}} 
with metrics_kpi as (
select  
        {{source('metrics_sequences','METRIC_KPI_ID')}}.nextval as METRIC_KPI_ID,
		a.METRIC_KPI_SNAP_DT,
        a.METRIC_ID,
        a.DIM_PRODUCT_TYPE_ID,
        a.DIM_BUSINESS_UNIT_ID,
        a.METRIC_DATE,
        a.DIM_METRIC_DATE_ID,
        a.METRIC_KPI_VALUE,
        a.METRIC_ANALYSIS_LEVEL1,
        a.METRIC_ANALYSIS_LEVEL2,
        a.METRIC_ANALYSIS_LEVEL3,
        a.METRIC_OVERRIDE_INDC,
        a.METRIC_OVERRIDE_USER_ID,
        a.SOURCE_SYSTEM_ID,
        a.SRC_SOURCE_SYSTEM_ID,
        a.SRC_UNIQ_CD,
        a.DEL_INDC,
        a.ROW_CRE_DT,
        a.ROW_CRE_USR_ID,
        a.ROW_MOD_DT,
        a.ROW_MOD_USR_ID
from {{ref('intr_metrics_kpi')}}  a
)    
select * from metrics_kpi
