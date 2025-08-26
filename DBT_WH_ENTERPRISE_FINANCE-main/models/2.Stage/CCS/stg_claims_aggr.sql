{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_claims_aggr as (
        select
            coalesce(b.dimclientkey, a.dimclientkey) as client,
            coalesce(b.product_type, a.product_type) as producttype,
            case
                when b.tranyearmonth is null
                then a.tranyearmonth
                else b.tranyearmonth
            end as tranyearmonthdate,
            z.src_sys_id,
            z.businessunit,
            concat(z.src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', z.src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', z.businessunit) as srcuniqcd_dim_business_unit,
            min(z.ptfm_min_dt) as ptfm_min_dt,
            coalesce(sum(a.claimcount), 0.00) as claimcount,
            coalesce(sum(a.cmcharges), 0.00) as cmcharges,
            coalesce(sum(a.Charged_Amount), 0.00) as cmallowed,
            coalesce(sum(a.claimcountisdisputed), 0.00) as claimcountisdisputed,
            coalesce(sum(b.cmallowedhit), 0.00) as cmallowedhit,
            coalesce(sum(b.claimcountrepriced), 0.00) as claimcountrepriced,
            coalesce(sum(b.savingsgross), 0.00) as savingsgross,
            case
                when (sum(b.savingsgross) > 0.00 and sum(b.cmallowedhit) > 0.00)
                then sum(b.savingsgross) / sum(b.cmallowedhit)
                else 0.00
            end as savingsrate,
            case
                when (sum(b.cmallowedhit) > 0.00 and sum(a.Charged_Amount) > 0)
                then sum(b.cmallowedhit) / sum(a.Charged_Amount)
                else 0.00
            end as hitrate

        from {{ ref("stg_revenue_claims_unique") }} z
        left outer join
            {{ ref("stg_revenue_claims_charge_aggr") }} a
            on (
                z.cmid = a.cmid
                and z.dimclientkey = a.dimclientkey
                and z.tranyearmonth = a.tranyearmonth
                and z.product_type = a.product_type
            )
        left outer join
            {{ ref("stg_revenue_claims_revenue_aggr") }} b
            on (
                z.cmid = b.cmid
                and z.dimclientkey = b.dimclientkey
                and z.tranyearmonth = b.tranyearmonth
                and z.product_type = b.product_type
            )

        group by
            client,
            producttype,
            tranyearmonthdate,
            z.src_sys_id,
            z.businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit

    )
select *
from stg_claims_aggr
