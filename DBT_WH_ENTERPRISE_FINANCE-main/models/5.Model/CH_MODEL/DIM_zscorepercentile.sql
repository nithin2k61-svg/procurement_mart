{{ config(materialized="view") }}

with
    dim_zscorepercentile as (
        select percentile, z_from, z_to
        from {{ source("ads_reporting_sources", "DIM_ZSCORE_PERCENTILE") }}
    )
select * from dim_zscorepercentile