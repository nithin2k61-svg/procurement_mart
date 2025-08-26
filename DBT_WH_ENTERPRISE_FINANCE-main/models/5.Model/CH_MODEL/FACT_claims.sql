{{ config(materialized="view") }}

with
    fact_claims as (
        select
            fc.dim_client_id,
            fc.dim_product_type_id,
            fc.dim_source_system_id,
            fc.dim_business_unit_id,
            fc.dim_date_id,
            to_timestamp_ntz(dd.dateday) dateday,
            pt."Product Type Group Rank" "Product Type Group ID",
            fc.ptfm_min_dt "Minimum Platform Date",
            case when claimcount = 0.000 then null else claimcount end claimcount,
            case when cmcharges = 0.000 then null else cmcharges end billedcharges,
            case when cmallowed = 0.000 then null else cmallowed end allowedcharges,
            case
                when claimcountisdisputed = 0.000 then null else claimcountisdisputed
            end claimcountisdisputed,
            case
                when cmallowedhit = 0.000 then null else cmallowedhit
            end allowedchargeswithsavings,
            case
                when claimcountrepriced = 0.000 then null else claimcountrepriced
            end claimcountrepriced,
            case when savingsgross = 0.000 then null else savingsgross end savingsgross

        from {{ ref("fact_claims_aggr") }} fc

        inner join
            {{ ref('dim_date') }} dd
            on dd.dim_date_id = fc.dim_date_id

        inner join {{ ref("DIM_product_type_ch") }} pt
            on fc.dim_product_type_id = pt.dim_product_type_id

        where dd.dateday < date_trunc('MONTH', getdate())
    )
select * from fact_claims