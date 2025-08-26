{{ config(materialized="table", tags=["monthly"]) }}

with
    intr_fact_claims_aggr as (
        select
            case
                when a.dim_client_id is null then -1 else a.dim_client_id
            end dim_client_id,
            case
                when b.dim_product_type_id is null then -1 else b.dim_product_type_id
            end dim_product_type_id,
            case
                when c.dim_source_system_id is null then -1 else c.dim_source_system_id
            end dim_source_system_id,
            case
                when d.dim_business_unit_id is null then -1 else d.dim_business_unit_id
            end dim_business_unit_id,
            case when e.DIM_DATE_ID is null then -1 else e.DIM_DATE_ID end DIM_DATE_ID,
            min(z.ptfm_min_dt) as ptfm_min_dt,            
            coalesce(sum(z.claimcount), 0.00) as claimcount,
            coalesce(sum(z.cmcharges), 0.00) as cmcharges,
            coalesce(sum(z.cmallowed), 0.00) as cmallowed,
            coalesce(sum(z.claimcountisdisputed), 0.00) as claimcountisdisputed,
            coalesce(sum(z.cmallowedhit), 0.00) as cmallowedhit,
            coalesce(sum(z.claimcountrepriced), 0.00) as claimcountrepriced,
            coalesce(sum(z.savingsgross), 0.00) as savingsgross,
            coalesce(sum(z.savingsrate), 0.00) as savingsrate,
            coalesce(sum(z.hitrate), 0.00) as hitrate
        from {{ ref("stg_claims_aggr") }} z
        left outer join
            {{ ref("dim_client") }} a on (z.srcuniqcd_dim_client = a.src_uniq_cd)
        left outer join
            {{ ref("dim_product_type") }} b
            on (z.srcuniqcd_dim_product_type = b.src_uniq_cd)
        left outer join
            {{ ref("dim_source_system") }} c
            on (z.srcuniqcd_dim_source_system = c.src_uniq_cd)
        left outer join
            {{ ref("dim_business_unit") }} d
            on (z.srcuniqcd_dim_business_unit = d.src_uniq_cd)
        left outer join
            {{ ref("dim_date") }} e
            on (z.tranyearmonthdate = e.dateday)
        group by
            a.dim_client_id,
            b.dim_product_type_id,
            c.dim_source_system_id,
            d.dim_business_unit_id,
            e.DIM_DATE_ID
    )
select
    dim_client_id,
    dim_product_type_id,
    dim_source_system_id,
    dim_business_unit_id,
    DIM_DATE_ID,
    ptfm_min_dt,
    claimcount,
    cmcharges,
    cmallowed,
    claimcountisdisputed,
    cmallowedhit,
    claimcountrepriced,
    savingsgross,
    savingsrate,
    hitrate,
    concat(
        dim_client_id,
        '_',
        dim_product_type_id,
        '_',
        dim_source_system_id,
        '_',
        dim_business_unit_id,
        '_',
        DIM_DATE_ID
    ) as src_uniq_cd,
    getdate() as row_cre_dt,
    'SFAdmin' as row_cre_usr_id,
    getdate() as row_mod_dt,
    'SFAdmin' as row_mod_usr_id
from intr_fact_claims_aggr
