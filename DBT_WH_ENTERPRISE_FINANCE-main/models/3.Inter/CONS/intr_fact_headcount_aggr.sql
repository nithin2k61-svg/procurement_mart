{{ config(materialized="table") }}

with intr_fact_headcount_aggr as (
select
case when a.dim_client_id is null then -1 else a.dim_client_id end dim_client_id,
case when b.dim_product_type_id is null then -1 else b.dim_product_type_id end DIM_PRODUCT_TYPE_ID,
case when c.dim_source_system_id is null then -1 else c.dim_source_system_id end DIM_SOURCE_SYSTEM_ID,
case when d.dim_business_unit_id is null then -1 else d.dim_business_unit_id end DIM_BUSINESS_UNIT_ID,
case when f.DIM_PROVIDER_ID is null then -1 else f.DIM_PROVIDER_ID end DIM_PROVIDER_ID,
case when e.dim_date_id is null then -1 else e.dim_date_id end dim_date_id,
z.ACCOUNT_NAME as ACCOUNT_NAME,
z.LEVEL_NAME as LEVEL_NAME,
z.TRAN_TYP as TRAN_TYP,
coalesce(sum(z.TOTAL_COUNT),0) as TOTAL_COUNT,
z.src_sys_id as  SRC_SYS_ID,
concat(a.dim_client_id,'_',dim_product_type_id,'_',dim_source_system_id,'_',dim_business_unit_id ) as src_uniq_cd,
getdate() as row_cre_dt,
'SFAdmin' as row_cre_usr_id,
getdate() as row_mod_dt,
'SFAdmin' as row_mod_usr_id

from {{ref('stg_headcount_aggr')}} z
left outer join {{ ref("dim_client") }} a
    on (z.srcuniqcd_dim_client = a.src_uniq_cd)
left outer join {{ref('dim_product_type')}} b
    on (z.srcuniqcd_dim_product_type = b.src_uniq_cd)
left outer join  {{ref('dim_source_system')}} c
    on (z.srcuniqcd_dim_source_system = c.src_uniq_cd)
left outer join {{ref('dim_business_unit')}} d
    on (z.srcuniqcd_dim_business_unit = d.src_uniq_cd)
left outer join {{ ref("dim_date") }} e
    on try_to_date(z.DATEKEY, 'MONYYYY') = e.dateday
left outer join {{ref('dim_provider')}} f
    on (z.srcuniqcd_dim_provider = f.src_uniq_cd)    
group by
    a.dim_client_id,
    b.DIM_PRODUCT_TYPE_ID,
    c.DIM_SOURCE_SYSTEM_ID,
    d.DIM_BUSINESS_UNIT_ID,
    z.TRAN_TYP,
    e.dim_date_id,
    z.src_sys_id,
    f.DIM_PROVIDER_ID,
    z.ACCOUNT_NAME,
    z.LEVEL_NAME    
)
select * from intr_fact_headcount_aggr
