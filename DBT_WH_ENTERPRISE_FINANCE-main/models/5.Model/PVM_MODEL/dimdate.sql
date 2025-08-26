{{ config(materialized="view") }}

with
    dimdate as (
        select
            BUSINESSDAY,
            DATEDAY "Date Day",
            DATEHALF "Date Half",
            DATEMONTH "Date Month",
            DATEQUARTER "Date Quarter",
            IFNULL(CASE WHEN DATEDAYOFWEEK = 'Sunday' then lag(DATEWEEK,7) OVER (ORDER BY DATEDAY) else DATEWEEK END, 'Week-1') "Date Week",
            DATEYEAR "Date Year",
            datehalfid,
            datemonthid,
            datequarterid,
            IFNULL(CASE WHEN DATEDAYOFWEEK = 'Sunday' then lag(DATEWEEKID,7) OVER (ORDER BY DATEDAY) else DATEWEEKID END, CONCAT(DATEYEAR,'01')) DATEWEEKID,
            DATEDAYOFMONTH "Day of Month",
            DATEDAYOFWEEK "Day of Week",
            DATEDAYOFYEAR "Day of Year",
            DATEDIFF(DAY,DATEDAY,GETDATE()) as DAYOFFSET,
            DAY(DATEDAY) as DAYSORTVALUE,
            dim_date_id,
            DATEDAYEXCLUDEWEEKENDS "Excluding Weekends",
            CONCAT(DATEMONTH,' ',DATEYEAR) "Month Year",
            CONCAT(LEFT(DATEMONTH,3), ' ',DATEYEAR) "MON YEAR",
            DATEDIFF(MONTH,DATEDAY,GETDATE()) as MONTHOFFSET,
            MONTH(DATEDAY) as MONTHSORTVALUE,
            DATEDIFF(QUARTER,DATEDAY,GETDATE()) as QUARTEROFFSET,
            QUARTER(DATEDAY) as QUARTERSORTVALUE,
            IFNULL(CASE WHEN DATEDAYOFWEEK = 'Sunday' then lag(WEEKID,7) OVER (ORDER BY DATEDAY) else WEEKID END, 1) AS WeekID,
            DATEDIFF(WEEK,DATEDAY,GETDATE())as WEEKOFFSET,
            DATEDIFF(YEAR,DATEDAY,GETDATE()) as YEAROFFSET,
            case
                when
                    "Date Day" >= to_date(dateadd(year, -3, dateadd(day, - (day(getdate()) - 1), getdate())))
                    and "Date Day" <= to_date(dateadd(day, - day(getdate()), getdate()))
                then 1
                else 0
            end as LAST3YEARSFLAG,
            dateadd(month, -1, "Date Day") lastmonthdateday,
            to_date(concat("Date Year", '-', right(datemonthid, 2), '-01')) monthbegindate,
            case
                when
                    concat(left("Date Month", 3), "Date Year") = concat(monthname(dateadd(day, -1, dateadd(month, -1, current_date()))), year(dateadd(day, -1, dateadd(month, -1, current_date()))))
                then 'Yes'
                else 'No'
            end as ispriormonth
        from {{ ref('dim_date') }}
        where
            (year("Date Day") * 100 + month("Date Day")) < (year(getdate()) * 100 + month(getdate()))
            and year("Date Day") >= year(getdate()) - 3
    )
select * from dimdate