{{ config(materialized="table", tags=["monthly"]) }}

with intr_fact_lrp_revenue_aggr as (
        select
           /* case
                when a.dim_client_id is null then -1 else a.dim_client_id
            end dim_client_id,*/
            -1 as dim_client_id,
            case
                when b.dim_product_type_id is null then -1 else b.dim_product_type_id
            end dim_product_type_id,
            case
                when c.dim_source_system_id is null then -1 else c.dim_source_system_id
            end dim_source_system_id,
            case
                when d.dim_business_unit_id is null then -1 else d.dim_business_unit_id
            end dim_business_unit_id,
            case when e.dim_date_id is null then -1 else e.dim_date_id end dim_date_id,
            z.src_sys_id,
            coalesce(sum(z.revenue_amount), 0.00) as revenue_amount,
            -1 as dim_provider_id
        from {{ ref("stg_lrp_revenue_aggr") }} z
      /*  left outer join
            {{ ref("dim_client") }} a on (z.srcuniqcd_dim_client = a.src_uniq_cd) */
        left outer join
            {{ ref("dim_product_type") }} b
            on (z.srcuniqcd_dim_product_type = b.src_uniq_cd)
        left outer join
            {{ ref("dim_source_system") }} c
            on (z.srcuniqcd_dim_source_system = c.src_uniq_cd)
        left outer join
            {{ ref("dim_business_unit") }} d
            on (z.srcuniqcd_dim_business_unit = d.src_uniq_cd)
        left outer join
            {{ ref("dim_date") }} e
            on (z.tranyearmonthdate = e.dateday)
        group by
           -- a.dim_client_id,
            b.dim_product_type_id,
            c.dim_source_system_id,
            d.dim_business_unit_id,
            e.dim_date_id,
            z.src_sys_id,
            dim_provider_id
)
select * from intr_fact_lrp_revenue_aggr       