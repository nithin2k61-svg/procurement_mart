{{ config(materialized='table') }}
WITH stg_dimdate AS (
SELECT 
DateCode,
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
FINANCEDAYS
FROM {{ source("calendar_sources", "DATE") }}
)
select *
from stg_dimdate