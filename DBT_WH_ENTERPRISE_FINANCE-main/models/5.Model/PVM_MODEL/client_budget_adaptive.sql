{{ config(materialized='view') }}

with client_budget_adaptive as (
SELECT DC.DIM_CLIENT_ID,
DBU.BUSINESSUNITNAME AS BUSINESSUNIT,
DC.financeparent , DC.CLIENTNAME,
D.DATEday AS DATEDAY,
DC.ACCOUNT_PARENT_NAME AS SF_PARENT ,
DC.Account_ID AS SalesForceID, P.PRODUCT_TYPE ,
SUM(T.REV_PLAN_PLAN) AS BUDGET_AMOUNT--,
FROM {{ref('fact_budgets_aggr')}} T
INNER JOIN {{ ref("dim_product_type") }} P ON T.DIM_PRODUCT_TYPE_ID=P.DIM_PRODUCT_TYPE_ID
INNER JOIN {{ ref("dim_date") }} D ON D.dim_date_id=T.dim_date_id
INNER JOIN {{ ref("dim_client") }} DC ON DC.DIM_CLIENT_ID=T.DIM_CLIENT_ID
INNER JOIN {{ ref("dim_source_system") }} DSS ON DSS.DIM_SOURCE_SYSTEM_ID=T.DIM_SOURCE_SYSTEM_ID
INNER JOIN {{ ref('dim_business_unit')}} DBU ON DBU.DIM_BUSINESS_UNIT_ID=T.DIM_BUSINESS_UNIT_ID
WHERE
DSS.SOURCESYSTEMNAME='ADAPTIVE' and P.PRODUCT_TYPE !='Others'
AND SUBSTR(D.DATEday,1,4) > 2021
GROUP BY 1,2,3,4,5,6,7,8
)

select * from client_budget_adaptive 