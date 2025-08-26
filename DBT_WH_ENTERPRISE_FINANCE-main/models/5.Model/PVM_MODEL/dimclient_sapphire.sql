{{ config(materialized='view') }}

with dimclient_sapphire as (
SELECT
    DISTINCT
    client.FINANCEPARENT "Client Parent"    
FROM {{ref('dim_client')}} client
INNER JOIN (SELECT DISTINCT FINANCEPARENT FROM {{ref('factpvm_sapphire')}}) spr
    on client.FINANCEPARENT = spr.FINANCEPARENT  
)

select * from dimclient_sapphire