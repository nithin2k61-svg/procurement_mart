{{ config(materialized="view") }}

with
    dim_product_type as (
        select distinct product_type, product_type_group, product_type_category
        from {{ ref("dim_product_type") }}
    )

select *
from dim_product_type
