{{ config(materialized='view') }}

with dimproducttype_sapphire as (
SELECT DISTINCT
    PRODUCT_TYPE dim_spr_product_type_id,
    PRODUCT_TYPE "Product Type",
    PRODUCT_TYPE_CATEGORY "Product Type Category"
    
FROM {{ref('dim_product_type')}} producttype
INNER JOIN (SELECT DISTINCT dim_spr_product_type_id FROM {{ ref('factpvm_sapphire')}}) spr
    on producttype.PRODUCT_TYPE = spr.dim_spr_product_type_id
)
select * from dimproducttype_sapphire