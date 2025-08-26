{{ config(materialized='view') }}

with factpvm_pps as (
SELECT 
    dat."Date Day" DATEDAY,
    pps.dim_date_id,
    client.financeparent as PAYERID,
    product.PRODUCT_TYPE as DIM_PPS_PRODUCT_TYPE_ID,
    CASE WHEN sum(pps.VOLUME_AMOUNT) = 0 OR product_type = 'SAAS' THEN NULL ELSE sum(pps.VOLUME_AMOUNT) END  CHARGED_AMOUNT,
    CASE WHEN sum(pps.NET_REVENUE_AMOUNT) = 0 THEN NULL ELSE sum(pps.NET_REVENUE_AMOUNT) END REVENUE_AMOUNT,
    product.PRODUCT_TYPE_CATEGORY    
FROM {{ref('fact_revenue_aggr')}} pps
INNER JOIN  {{ ref('dimdate')}} dat
    on dat.dim_date_id = pps.dim_date_id
INNER JOIN  {{ ref('dim_business_unit')}} business_unit
    on business_unit.dim_business_unit_id = pps.dim_business_unit_id
inner join  {{ ref("dim_product_type") }} product
    on product.dim_product_type_id = pps.dim_product_type_id
inner join  {{ ref("dim_client") }} client
    on client.dim_client_id = pps.dim_client_id
WHERE
    dat."Date Day" < DATE_TRUNC('MONTH',GETDATE())
and business_unit.BUSINESSUNITNAME in ('Payments', 'Communications')
and product.product_type_category in ('Payments/Comms')
and product.product_type not in ('Others')

GROUP BY
    dat."Date Day",
    pps.dim_date_id,
    client.financeparent,
    product.PRODUCT_TYPE,
    product.PRODUCT_TYPE_CATEGORY  
)

select * from factpvm_pps