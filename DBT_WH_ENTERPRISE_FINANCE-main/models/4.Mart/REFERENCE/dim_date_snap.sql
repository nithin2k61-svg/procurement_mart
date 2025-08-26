{{ config(materialized='incremental',incremental_strategy='append', tags=['monthly','snap_montly'],on_schema_change='sync_all_columns')}}

with dim_date_snap as (
select 
(select * from {{ref('stg_snap_datetime')}} ) as SNAP_DATETIME,
DATECODE,
DATEDAY,
DATEYEAR,
DATEHALFID,
DATEHALF,
DATEQUARTERID,
DATEQUARTER,
DATEMONTHID,
DATEMONTH,
DATEWEEKID,
DATEWEEK,
DATEDAYOFYEAR,
DATEDAYOFMONTH,
DATEDAYOFWEEK,
DATEDAYEXCLUDEWEEKENDS,
DATEMONTHSSRS,
BUSINESSDAY,
WEEKID,
FINANCEDAYS,
SRC_UNIQ_CD,
DEL_INDC,
ROW_CRE_DT,
ROW_CRE_USR_ID,
ROW_MOD_DT,
ROW_MOD_USR_ID
from {{ source('calendar_sources','DATE') }}
)
select * from dim_date_snap