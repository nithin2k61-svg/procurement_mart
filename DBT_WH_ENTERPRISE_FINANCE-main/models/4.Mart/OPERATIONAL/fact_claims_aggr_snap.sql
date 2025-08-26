{{ config(materialized='incremental',incremental_strategy='append', tags=['monthly','snap_montly'],on_schema_change='sync_all_columns')}}

with fact_claims_aggr_snap as (
select 
(select * from {{ref('stg_snap_datetime')}} ) as SNAP_DATETIME,
* from {{ ref('fact_claims_aggr') }}
)
select * from fact_claims_aggr_snap