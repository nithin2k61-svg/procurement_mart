{{ config(materialized="table",tags=['METRICS']) }}
with intr_solutions_revenue_actuals as (
select  
        z.METRIC_KPI_SNAP_DT,
        me.METRIC_ID,
        case
                when b.dim_product_type_id is null then -1 else b.dim_product_type_id
            end DIM_PRODUCT_TYPE_ID,
        case
                when bu.dim_business_unit_id is null then -1 else bu.dim_business_unit_id
            end DIM_BUSINESS_UNIT_ID,
        z.METRIC_DATE,
        dt.DIM_DATE_ID as DIM_METRIC_DATE_ID,
        z.METRIC_KPI_VALUE,
        z.METRIC_ANALYSIS_LEVEL1,
        z.METRIC_ANALYSIS_LEVEL2,
        z.METRIC_ANALYSIS_LEVEL3,
        z.METRIC_OVERRIDE_INDC,
        z.METRIC_OVERRIDE_USER_ID,
        z.SOURCE_SYSTEM_ID,
        z.SRC_SOURCE_SYSTEM_ID,
        z.SRC_UNIQ_CD,
        z.DEL_INDC,
        z.ROW_CRE_DT,
        z.ROW_CRE_USR_ID,
        z.ROW_MOD_DT,
        z.ROW_MOD_USR_ID
from {{ref('stg_sol_rev_fact_revenue_aggr')}} z
        inner join {{ref('metrics')}} me on me.src_uniq_cd = z.src_uniq_cd_METRIC_ID
        inner join {{ref('dim_date')}} dt on dt.src_uniq_cd = z.src_uniq_cd_METRIC_DATE_ID     
        left outer join
            {{ ref("dim_product_type") }} b
          on (z.src_uniq_cd_PRODUCT_TYPE_ID = b.src_uniq_cd)   
        left outer join
            {{ ref("dim_business_unit") }} bu
            on (z.src_uniq_cd_BUSINESS_UNIT_ID = bu.src_uniq_cd)
)        
select * from intr_solutions_revenue_actuals