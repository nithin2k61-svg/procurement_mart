{{ config(materialized='table',tags=['monthly']) }}
with stg_snap_datetime as (
select getdate() as Snap_DateTime 
)
select * from stg_snap_datetime