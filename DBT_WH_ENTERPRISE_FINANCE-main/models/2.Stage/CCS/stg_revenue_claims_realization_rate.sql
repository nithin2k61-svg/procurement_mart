{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_claims_realization_rate as (
        select
            dc.dimclientkey,
            rr.product product_type,
            rr.monthyear tranyearmonth,
            rr.realization_rate
        from {{ source("adaptive_comm_sources", "realization_rates") }} rr
        inner join
            {{ source("caidwh_sources", "dimclient") }} dc
            --on (rr.client_number = dc.clientnumber)
            on (rr.client_parent_name = dc.clientparentname)
/*        inner join
            {{ source("caidwh_sources", "dimdate") }} ddrk
            on (rr.monthyear = ddrk.dateday)
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(ddrk.dateday)) + 1), ddrk.dateday)
                = monthdate.dateday
            ) */
        where
            rr.monthyear >= '2019-01-01'
            and rr.product in ('HBR', 'Claim Editing', 'Negotiations', 'PPO', 'RBP')
    )
select *
from stg_revenue_claims_realization_rate
