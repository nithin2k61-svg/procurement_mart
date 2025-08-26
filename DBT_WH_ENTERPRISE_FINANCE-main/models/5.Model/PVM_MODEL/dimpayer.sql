{{ config(materialized='view') }}

with dimpayer as (

SELECT DISTINCT
    payer.FINANCEPARENT PayerID,
    payer.FINANCEPARENT "Payer"    
FROM {{ref('dim_client')}} payer
INNER JOIN (SELECT DISTINCT PAYERID FROM {{ref('factpvm_pps')}}) pps
    on pps.PAYERID=payer.FINANCEPARENT
)
select * from dimpayer