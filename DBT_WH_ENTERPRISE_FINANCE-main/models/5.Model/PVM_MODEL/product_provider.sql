{{ config(materialized='view') }}
with product_provider as (
SELECT DISTINCT
              PRODUCT_TYPE as DIM_PPS_PRODUCT_TYPE_ID,
              PRODUCT_TYPE "Product Type",
              CASE WHEN PRODUCT_TYPE_CATEGORY = 'Payments/Comms' then PRODUCT_TYPE else PRODUCT_TYPE_CATEGORY END as "Product Type Category",
              CASE WHEN PRODUCT_TYPE_CATEGORY = 'Payments/Comms' then 0 else 1 END as "Product Type Category Flag"
          FROM {{ ref("dim_product_type") }} ProductType
          INNER JOIN (SELECT DISTINCT
              product.PRODUCT_TYPE as DIM_PPS_PRODUCT_TYPE_ID
          FROM {{ref('fact_revenue_aggr')}} pps
          INNER JOIN  {{ ref('dimdate')}} dat
              on dat.dim_date_id = pps.dim_date_id
          INNER JOIN  {{ ref('dim_business_unit')}} business_unit
              on business_unit.dim_business_unit_id = pps.dim_business_unit_id
          inner join  {{ ref("dim_product_type") }}  product
              on product.dim_product_type_id = pps.dim_product_type_id
          WHERE
              dat."Date Day" < DATE_TRUNC('MONTH',GETDATE())
          and business_unit.BUSINESSUNITNAME in ('Payments', 'Communications')
          and product.product_type not in ('Others','Unknown')) pps
              on ProductType.PRODUCT_TYPE = pps.DIM_PPS_PRODUCT_TYPE_ID
)
select * from product_provider