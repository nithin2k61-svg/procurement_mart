{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_claims_unique as (
        select distinct
            cmid,
            dimclientkey,
            tranyearmonth,
            product_type,
            src_sys_id,
            businessunit,
            ptfm_min_dt
        from {{ ref("stg_revenue_claims_charge_aggr") }}
        union
        select distinct
            cmid,
            dimclientkey,
            tranyearmonth,
            product_type,
            src_sys_id,
            businessunit,
            ptfm_min_dt
        from {{ ref("stg_revenue_claims_revenue_aggr") }}
    )
select *
from stg_revenue_claims_unique
