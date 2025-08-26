{{ config(materialized="view") }}

with
    dim_source_system as (
        select dim_source_system_id, sourcesystemname as "Source System"
        from {{ ref("dim_source_system") }}
    )
select * from dim_source_system