{{ config(materialized='view') }}
with PPS_Payer_Products as 
(SELECT 
    pps.dim_date_id as dim_date_id ,
    client.financeparent as PAYERID,
    product.PRODUCT_TYPE as DIM_PPS_PRODUCT_TYPE_ID,
    CASE WHEN sum(CASE WHEN product_type = 'SAAS' then 0 ELSE ROUND(pps.VOLUME_AMOUNT,2) END) = 0 THEN NULL ELSE sum(CASE WHEN product_type = 'SAAS' then 0 ELSE ROUND(pps.VOLUME_AMOUNT,2) END) END CHARGED_AMOUNT,
    CASE WHEN sum(CASE WHEN DIM_PROVIDER_ID = -1 THEN pps.NET_REVENUE_AMOUNT ELSE ROUND(pps.GROSS_REVENUE_AMOUNT,2) END) = 0 THEN NULL ELSE sum(CASE WHEN DIM_PROVIDER_ID = -1 THEN pps.NET_REVENUE_AMOUNT ELSE ROUND(pps.GROSS_REVENUE_AMOUNT,2) END) END REVENUE_AMOUNT,
    DIM_PROVIDER_ID
FROM {{ ref('fact_revenue_aggr') }} pps
INNER JOIN  {{ ref('dimdate') }} dat
    on dat.dim_date_id = pps.dim_date_id
INNER JOIN  {{ ref('dim_business_unit') }} business_unit
    on business_unit.dim_business_unit_id = pps.dim_business_unit_id
inner join  {{ ref('dim_product_type') }} product
    on product.dim_product_type_id = pps.dim_product_type_id
inner join  {{ ref('dim_client') }} client
    on client.dim_client_id = pps.dim_client_id
WHERE
    dat."Date Day" < DATE_TRUNC('MONTH',GETDATE())
and business_unit.BUSINESSUNITNAME in ('Payments', 'Communications')
and product.product_type_Category not in ('Payments/Comms','Unknown')
AND(product.PRODUCT_TYPE NOT IN ('ACH+-Settled','VCC-Settled','EPC Payer-Sponsored') OR
(product.PRODUCT_TYPE IN ('ACH+-Settled','VCC-Settled','EPC Payer-Sponsored') AND DIM_PROVIDER_ID <> -1))
GROUP BY
    pps.dim_date_id,
    client.financeparent,
    product.PRODUCT_TYPE,
    DIM_PROVIDER_ID
)
,factpvm_pps_payer_products as 
(
select 
    dim_date_id,
    PAYERID,
    DIM_PPS_PRODUCT_TYPE_ID,
    sum(CHARGED_AMOUNT) as CHARGED_AMOUNT ,
    sum(REVENUE_AMOUNT) as REVENUE_AMOUNT
    from PPS_Payer_Products
GROUP BY
    dim_date_id,
    PAYERID,
    DIM_PPS_PRODUCT_TYPE_ID
)

select * from factpvm_pps_payer_products