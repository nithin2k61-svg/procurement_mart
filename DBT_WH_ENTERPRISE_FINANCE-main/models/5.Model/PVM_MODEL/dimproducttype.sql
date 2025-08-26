{{ config(materialized='view') }}

with dimproducttype as (
SELECT DISTINCT
    PRODUCT_TYPE DIM_CCS_PRODUCT_TYPE_ID,
    PRODUCT_TYPE "Product Type",
    PRODUCT_TYPE_CATEGORY "Product Type Category"
    
FROM {{ref('dim_product_type')}} producttype
INNER JOIN (SELECT DISTINCT DIM_CCS_PRODUCT_TYPE_ID FROM {{ ref('factpvm_ccs')}}) ccs
    on producttype.PRODUCT_TYPE = ccs.DIM_CCS_PRODUCT_TYPE_ID
)
select * from dimproducttype