{{ config(materialized="view") }}

with
    fact_revenue_refresh as (
        select
            row_number() over (order by datequarterid) "PartitionNumber",
            to_timestamp("RangeStart") "RangeStart",
            rowupdated
        from
            (
                select distinct
                    datequarterid, min("Date Day") "RangeStart", max(row_mod_dt) rowupdated
                from {{ ref("fact_revenue_aggr") }} fc
                join {{ ref("dimdate") }} dd
                    on fc.dim_date_id = dd.dim_date_id
                where
                    "Date Day" between dateadd(quarter, -21, to_date(getdate())) and to_date(getdate())
                group by datequarterid
            ) t
        where day("RangeStart") = 1
    )
select * 
from fact_revenue_refresh