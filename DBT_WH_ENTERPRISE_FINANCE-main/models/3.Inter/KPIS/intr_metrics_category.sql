{{ config(materialized="table",tags=['METRICS']) }}
with intr_metrics_category as (
select DISTINCT
        mc.METRIC_CATEGORY_CODE,
        mc.METRIC_CATEGORY_DESCRIPTION,
        mu1.METRIC_USER_ID as METRIC_CATEGORY_OWNER_ID,
        mu2.METRIC_USER_ID as METRIC_CATEGORY_APPROVER_ID,
        mc.SOURCE_SYSTEM_ID,
        mc.SRC_UNIQ_CD,
        mc.DEL_INDC,
        mc.ROW_CRE_DT,
        mc.ROW_CRE_USR_ID,
        mc.ROW_MOD_DT,
        mc.ROW_MOD_USR_ID
        from {{ref('stg_metrics_category')}} mc
        inner join {{ref('metrics_user')}} mu1 on mu1.src_uniq_cd = mc.SRC_UNIQ_CD_METRIC_CATEGORY_OWNER
        inner join {{ref('metrics_user')}} mu2 on mu2.src_uniq_cd = mc.SRC_UNIQ_CD_METRIC_CATEGORY_APPROVER
)    
select * from intr_metrics_category