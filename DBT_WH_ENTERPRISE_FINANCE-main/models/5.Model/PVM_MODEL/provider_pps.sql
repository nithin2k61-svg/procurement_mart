{{ config(materialized='view') }}
with Provider_PPS as (
SELECT DISTINCT
p.DIM_PROVIDER_ID,
p.NAME as Provider_Name,
CONCAT(p.PROVIDERID,'-', NAME) "Combined Provider Name",
TIN,
NPI,
STREET1 as Provider_Address_1,
STREET2 as Provider_Address_2,
CITY as Provider_City,
State as Provider_State,
POSTALCODE as Provider_ZIP
FROM  {{ ref('dim_provider') }} p
JOIN (
SELECT DISTINCT
DIM_PROVIDER_ID
FROM {{ref('fact_revenue_aggr')}} pps
INNER JOIN  {{ ref('dimdate')}} dat
    on dat.dim_date_id = pps.dim_date_id
INNER JOIN {{ ref('dim_business_unit')}} business_unit
    on business_unit.dim_business_unit_id = pps.dim_business_unit_id
inner join  {{ ref("dim_product_type") }} product
    on product.dim_product_type_id = pps.dim_product_type_id
WHERE
    dat."Date Day" < DATE_TRUNC('MONTH',GETDATE())
and business_unit.BUSINESSUNITNAME in ('Payments', 'Communications')
and product.product_type not in ('Others')
) f on f.DIM_PROVIDER_ID = p.DIM_PROVIDER_ID
)
select * from Provider_PPS