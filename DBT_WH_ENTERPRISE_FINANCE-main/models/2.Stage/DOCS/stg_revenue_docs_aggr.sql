{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_docs_aggr as (
        select
            pyre.cclientid client,
            pyre.product_type as producttype,
            monthdate.dateday as tranyearmonthdate,
            pyre.src_sys_id,
            pyre.businessunit,
            concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            coalesce(sum(quantity), 0) volume_amount,
            coalesce(sum(rate * quantity), 0) gross_revenue_amount,
            1 as realization_rate,
            0 as net_revenue_amount

        from {{ ref("stg_revenue_docs") }} pyre
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(
                    day, ((-1 * day(transaction_yearmonth)) + 1), transaction_yearmonth
                )
                = monthdate.dateday
            )

        group by
            client,
            producttype,
            tranyearmonthdate,
            src_sys_id,
            businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system ,
            srcuniqcd_dim_business_unit
    )
select *
from stg_revenue_docs_aggr
