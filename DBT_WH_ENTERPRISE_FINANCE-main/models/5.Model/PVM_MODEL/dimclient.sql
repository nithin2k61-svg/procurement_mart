{{ config(materialized='view') }}

with dimclient as (
SELECT
    DISTINCT
    client.FINANCEPARENT "Client Parent"    
FROM {{ref('dim_client')}} client
INNER JOIN (SELECT DISTINCT FINANCEPARENT FROM {{ref('factpvm_ccs')}}) ccs
    on client.FINANCEPARENT = ccs.FINANCEPARENT  
)

select * from dimclient