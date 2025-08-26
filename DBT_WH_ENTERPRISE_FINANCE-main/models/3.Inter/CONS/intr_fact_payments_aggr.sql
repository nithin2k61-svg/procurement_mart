{{ config(materialized="table", tags=["monthly"]) }}

with
    intr_fact_payments_aggr as (
        select
            case
                when a.dim_client_id is null then -1 else a.dim_client_id
            end dim_client_id,
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
            min(z.ptfm_min_dt) as ptfm_min_dt,            
            coalesce(sum(z.pps_count), 0.00) as pps_count,
            coalesce(sum(z.pps_amount), 0.00) as pps_amount,
            coalesce(avg(z.pps_adopt_rate), 0.00) as pps_adopt_rate
        from {{ ref("stg_payments_aggr") }} z
        left outer join
            {{ ref("dim_client") }} a on (z.srcuniqcd_dim_client = a.src_uniq_cd)
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
            a.dim_client_id,
            b.dim_product_type_id,
            c.dim_source_system_id,
            d.dim_business_unit_id,
            e.dim_date_id
    )
select
    dim_client_id,
    dim_product_type_id,
    dim_source_system_id,
    dim_business_unit_id,
    dim_date_id,
    ptfm_min_dt,
    pps_count,
    pps_amount,
    pps_adopt_rate,
    concat(
        dim_client_id,
        '_',
        dim_product_type_id,
        '_',
        dim_source_system_id,
        '_',
        dim_business_unit_id,
        '_',
        dim_date_id
    ) as src_uniq_cd,
    getdate() as row_cre_dt,
    'SFAdmin' as row_cre_usr_id,
    getdate() as row_mod_dt,
    'SFAdmin' as row_mod_usr_id
from intr_fact_payments_aggr
