{{ config(materialized="view") }}

with
    dim_business_unit as (
        select dim_business_unit_id, businessunitname as "Business Unit"
        from {{ ref("dim_business_unit") }}
    )
select * from dim_business_unit