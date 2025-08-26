{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_ccs_aggr as (
        select
            coalesce(b.dimclientkey, a.dimclientkey) as client,
            coalesce(b.product_type, a.product_type) as producttype,
            case
                when b.tranyearmonth is null
                then a.tranyearmonth
                else b.tranyearmonth
            end as tranyearmonthdate, 
            z.src_sys_id,
            z.businessunit,
            concat(z.src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', z.src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', z.businessunit) as srcuniqcd_dim_business_unit,
            coalesce(sum(a.charged_amount), 0.00) as volume_amount,
            coalesce(sum(b.revenue_amount), 0.00) as gross_revenue_amount,
            nvl(realization_rate, 0) as realization_rate ,
            0 as net_revenue_amount

        from {{ ref("stg_revenue_claims_unique") }} z
        left outer join
            {{ ref("stg_revenue_claims_charge_aggr") }} a
            on (
                z.cmid = a.cmid
                and z.dimclientkey = a.dimclientkey
                and z.tranyearmonth = a.tranyearmonth
                and z.product_type = a.product_type
            )
        left outer join
            {{ ref("stg_revenue_claims_revenue_aggr") }} b
            on (
                z.cmid = b.cmid
                and z.dimclientkey = b.dimclientkey
                and z.tranyearmonth = b.tranyearmonth
                and z.product_type = b.product_type
            )
        left outer join
            {{ ref("stg_revenue_claims_realization_rate") }} c
            on (
                z.dimclientkey = c.dimclientkey
                and z.tranyearmonth = c.tranyearmonth
                and z.product_type = c.product_type
            )

        group by
            client,
            producttype,
            tranyearmonthdate,
            realization_rate,
            z.src_sys_id,
            z.businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit

    )
select *
from stg_revenue_ccs_aggr
