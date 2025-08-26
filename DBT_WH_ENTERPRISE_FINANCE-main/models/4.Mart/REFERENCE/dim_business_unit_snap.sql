{{ config(materialized='incremental',incremental_strategy='append', tags=['monthly','snap_montly'],on_schema_change='sync_all_columns')}}

with dim_business_unit_snap as (
select 
(select * from {{ref('stg_snap_datetime')}} ) as SNAP_DATETIME,
* from {{ ref('dim_business_unit') }}
)
select * from dim_business_unit_snap