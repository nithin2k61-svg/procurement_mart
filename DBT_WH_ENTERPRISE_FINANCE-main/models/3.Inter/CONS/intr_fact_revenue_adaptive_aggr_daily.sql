{{ config(materialized="table") }}

With Final As
(
SELECT
case when a.dim_client_id is null then -1 else a.dim_client_id end DIM_CLIENT_ID,
case when b.dim_product_type_id is null then -1 else b.dim_product_type_id end DIM_PRODUCT_TYPE_ID,
case when c.dim_source_system_id is null then -1 else c.dim_source_system_id end DIM_SOURCE_SYSTEM_ID,
case when d.dim_business_unit_id is null then -1 else d.dim_business_unit_id end DIM_BUSINESS_UNIT_ID,
case when f.DIM_PROVIDER_ID is null then -1 else f.DIM_PROVIDER_ID end DIM_PROVIDER_ID,
case when dim_date_id is null then -1 else dim_date_id end dim_date_id,
z.ACCOUNT_NAME,
z.LEVEL_NAME,
z.REVENUE_GL_ACCOUNT,
z.DAILYAMOUNT_ACTUALS,
z.DAILYAMOUNT_PLAN,
z.DAILYAMOUNT_FORECAST,
z.SOURCE_SYSTEM_ID as  SRC_SYS_ID,
getdate() as row_cre_dt,
'SFAdmin' as row_cre_usr_id,
getdate() as row_mod_dt,
'SFAdmin' as row_mod_usr_id
from {{ref('stg_revenue_adaptive_aggr_daily')}} z
left outer join {{ ref("dim_client") }} a
    on (z.srcuniqcd_dim_client = a.src_uniq_cd)
left outer join {{ref('dim_product_type')}} b
    on (z.srcuniqcd_dim_product_type = b.src_uniq_cd)
left outer join  {{ref('dim_source_system')}} c
    on (z.srcuniqcd_dim_source_system = c.src_uniq_cd)
left outer join {{ref('dim_business_unit')}} d
    on (z.srcuniqcd_dim_business_unit = d.src_uniq_cd) 
left outer join {{ref('dim_provider')}} f
    on (z.srcuniqcd_dim_provider = f.src_uniq_cd) 
)
, intr_fact_revenue_adaptive_aggr_Daily As 
(
 SELECT

DIM_CLIENT_ID,
DIM_PRODUCT_TYPE_ID,
DIM_SOURCE_SYSTEM_ID,
DIM_BUSINESS_UNIT_ID,
DIM_PROVIDER_ID,
dim_date_id,
ACCOUNT_NAME,
LEVEL_NAME,
REVENUE_GL_ACCOUNT,
DAILYAMOUNT_ACTUALS,
DAILYAMOUNT_PLAN,
DAILYAMOUNT_FORECAST,
SRC_SYS_ID,
concat(DIM_CLIENT_ID,'_',DIM_PRODUCT_TYPE_ID,'_',DIM_SOURCE_SYSTEM_ID,'_',DIM_BUSINESS_UNIT_ID,'_',dim_date_id,'_',DIM_PROVIDER_ID,'_',ACCOUNT_NAME,'_',LEVEL_NAME,'_',REVENUE_GL_ACCOUNT) as SRC_UNIQ_CD,
row_cre_dt,
row_cre_usr_id,
row_mod_dt,
row_mod_usr_id
FROM Final   
)
SELECT * FROM intr_fact_revenue_adaptive_aggr_Daily
