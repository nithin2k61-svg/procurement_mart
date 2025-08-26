{{ config(materialized="table", tags=["monthly"]) }}
With fact_revenue_adaptive_aggr_daily
as
(
SELECT
A.DIM_CLIENT_ID,
A.dim_product_type_id,
A.dim_source_system_id,
A.dim_business_unit_id,
A.DIM_PROVIDER_ID,
A.dim_date_id,
A.ACCOUNT_NAME,
A.LEVEL_NAME,
A.REVENUE_GL_ACCOUNT,
A.DAILYAMOUNT_ACTUALS,
A.DAILYAMOUNT_PLAN,
A.DAILYAMOUNT_FORECAST,
A.src_uniq_cd,
A.row_cre_dt,
A.row_cre_usr_id,
A.row_mod_dt,
A.row_mod_usr_id
from {{ ref('intr_fact_revenue_adaptive_aggr_daily') }} as A
)
Select * From fact_revenue_adaptive_aggr_Daily