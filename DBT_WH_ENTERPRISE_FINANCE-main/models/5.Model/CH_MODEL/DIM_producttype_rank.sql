{{ config(materialized="view") }}

with
    dim_producttype_rank as (
        select
            dim_product_type_id,
            product_type,
            product_type_group,
            /* CASE WHEN product_type_group = 'CLAIM EDITING' THEN 'CLAIMS EDITING' WHEN product_type_group = 'HBR' THEN 'HOSPITAL BILL REVIEW' ELSE product_type_group END,*/
            product_type_category,
            dense_rank() over (order by product_type_group) as product_type_group_rank
        from {{ ref("dim_product_type") }}
    )
select *
from dim_producttype_rank