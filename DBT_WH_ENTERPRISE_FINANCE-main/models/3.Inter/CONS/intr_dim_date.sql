{{ config(materialized='table') }}

with intr_dim_date as (
select
to_number(DATECODE) as dim_date_id,
DateDay,
DateYear,
DateHalfID,
DateHalf,
DateQuarterID,
DateQuarter,
DateMonthID,
DateMonth,
DateWeekID,
DateWeek,
DateDayofYear,
DateDayofMonth,
DateDayofWeek,
DATEDAYEXCLUDEWEEKENDS,
DATEMONTHSSRS,
BUSINESSDAY,
WeekID,
FINANCEDAYS,
DateCode as src_uniq_cd,
0 as del_indc,
getdate() as row_cre_dt,
'SF_Admin' as row_cre_usr_id,
getdate() as row_mod_dt,
'SF_Admin' as row_mod_usr_id
from {{ ref('stg_dimdate')}}
)

select * from intr_dim_date
