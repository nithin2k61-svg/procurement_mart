{{ config(materialized='incremental',incremental_strategy='append', tags=['monthly','snap_montly'],on_schema_change='sync_all_columns')}}

with dim_source_system_snap as (
select 
(select * from {{ref('stg_snap_datetime')}} ) as SNAP_DATETIME,
* from {{ ref('dim_source_system') }}
)
select * from dim_source_system_snap