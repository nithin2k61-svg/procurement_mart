{{ config(materialized='view') }}

with dimproducttype_pps as (
SELECT DISTINCT
    PRODUCT_TYPE as DIM_PPS_PRODUCT_TYPE_ID,
    PRODUCT_TYPE "Product Type",
    PRODUCT_TYPE_CATEGORY    
FROM {{ref('dim_product_type')}} ProductType
INNER JOIN (SELECT DISTINCT DIM_PPS_PRODUCT_TYPE_ID FROM {{ ref('factpvm_pps')}}) pps
    on ProductType.PRODUCT_TYPE = pps.DIM_PPS_PRODUCT_TYPE_ID
)
select * from dimproducttype_pps