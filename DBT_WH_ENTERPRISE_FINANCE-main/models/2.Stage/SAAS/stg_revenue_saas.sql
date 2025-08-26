{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_saas as (
        select
            pyre.client_number as client,
            pyre.product as producttype,
            monthdate.dateday as tranyearmonthdate,
            case
                when pyre.client_source_system = 'DOCS'
                then '3'
                when pyre.client_source_system = 'SAAS'
                then '4'
                when pyre.client_source_system = 'VPAY'
                then '5'
                else '-1'
            end as client_src_sys_id,
            4 as src_sys_id,
            '2' as businessunit,
            concat(client_src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            coalesce(sum(volume), 0) volume_amount,
            coalesce(sum(revenue), 0) gross_revenue_amount,
            1 as realization_rate,
            0 as net_revenue_amount

        from {{ source("docsshared_client_sources", "saasvpay_revenue") }} pyre
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(pyre.monthyear)) + 1), monthyear)
                = monthdate.dateday
            )

        where monthdate.dateyear >= 2019 and pyre.product = 'SAAS'

        group by
            client,
            producttype,
            businessunit,
            tranyearmonthdate,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            tranyearmonthdate,
            src_sys_id,
            pyre.client_source_system,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit

    )

select *
from stg_revenue_saas
