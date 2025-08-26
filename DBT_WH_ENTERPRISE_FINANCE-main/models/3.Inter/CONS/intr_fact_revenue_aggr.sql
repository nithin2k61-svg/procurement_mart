{{ config(materialized="table", tags=["monthly"]) }}

with intr_fact_revenue_aggr_ccs as (
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
            z.src_sys_id,
            coalesce(sum(z.volume_amount), 0.00) as volume_amount,
            coalesce(sum(z.gross_revenue_amount), 0.00) as gross_revenue_amount,
            coalesce(sum(z.realization_rate), 0.00) as realization_rate,
            coalesce(sum(z.net_revenue_amount), 0.00) as net_revenue_amount,
            -1 as dim_provider_id
        from {{ ref("stg_revenue_adaptive") }} z
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
            e.dim_date_id,
            z.src_sys_id,
            dim_provider_id

        union all

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
            z.src_sys_id,
            coalesce(sum(z.volume_amount), 0.00) as volume_amount,
            coalesce(sum(z.gross_revenue_amount), 0.00) as gross_revenue_amount,
            coalesce(sum(z.realization_rate), 0.00) as realization_rate,
            coalesce(sum(z.net_revenue_amount), 0.00) as net_revenue_amount,
            -1 as dim_provider_id
        from {{ ref("stg_revenue_ccs_aggr") }} z
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
            e.dim_date_id,
            z.src_sys_id,
            dim_provider_id
),
intr_fact_revenue_aggr_pps as (
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
            z.src_sys_id,
            coalesce(sum(z.volume_amount), 0.00) as volume_amount,
            coalesce(sum(z.gross_revenue_amount), 0.00) as gross_revenue_amount,
            coalesce(z.realization_rate, 0.00) as realization_rate,
            coalesce(sum(z.net_revenue_amount), 0.00) as net_revenue_amount,
            -1 as dim_provider_id
        from {{ ref("stg_revenue_docs_aggr") }} z
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
            e.dim_date_id,
            z.src_sys_id,
            z.realization_rate

        union all

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
            z.src_sys_id,
            coalesce(sum(z.volume_amount), 0.00) as volume_amount,
            coalesce(sum(z.gross_revenue_amount), 0.00) as gross_revenue_amount,
            coalesce(z.realization_rate, 0.00) as realization_rate,
            coalesce(sum(z.net_revenue_amount), 0.00) as net_revenue_amount,
             case
                when f.dim_provider_id is null then -1 else f.dim_provider_id
            end dim_provider_id
        from {{ ref("stg_revenue_pps_aggr") }} z
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
            left outer join
            {{ ref("dim_provider") }} f
            on (z.srcuniqcd_dim_provider = f.src_uniq_cd)
        group by
            a.dim_client_id,
            b.dim_product_type_id,
            c.dim_source_system_id,
            d.dim_business_unit_id,
            e.dim_date_id,
            z.src_sys_id,
            z.realization_rate,
            f.dim_provider_id

        union all

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
            z.src_sys_id,
            coalesce(sum(z.volume_amount), 0.00) as volume_amount,
            coalesce(sum(z.gross_revenue_amount), 0.00) as gross_revenue_amount,
            coalesce(z.realization_rate, 0.00) as realization_rate,
            coalesce(sum(z.net_revenue_amount), 0.00) as net_revenue_amount,
            -1 as dim_provider_id
        from {{ ref("stg_revenue_saas") }} z
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
            e.dim_date_id,
            z.src_sys_id,
            z.realization_rate,dim_provider_id

        union all

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
            z.src_sys_id,
            coalesce(sum(z.volume_amount), 0.00) as volume_amount,
            coalesce(sum(z.gross_revenue_amount), 0.00) as gross_revenue_amount,
            coalesce(z.realization_rate, 0.00) as realization_rate,
            coalesce(sum(z.net_revenue_amount), 0.00) as net_revenue_amount,
            -1 as dim_provider_id
        from {{ ref("stg_revenue_vpay") }} z
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
            e.dim_date_id,
            z.src_sys_id,
            z.realization_rate,
            dim_provider_id
    )
select
    dim_client_id,
    dim_product_type_id,
    dim_source_system_id,
    dim_business_unit_id,
    dim_date_id,
    src_sys_id,
    volume_amount,
    gross_revenue_amount,
    realization_rate,
    net_revenue_amount,
    dim_provider_id,
    concat(dim_client_id,'_',dim_product_type_id,'_',dim_source_system_id,'_',dim_business_unit_id,'_',dim_date_id,'_',dim_provider_id) as src_uniq_cd,
    getdate() as row_cre_dt,
    'SFAdmin' as row_cre_usr_id,
    getdate() as row_mod_dt,
    'SFAdmin' as row_mod_usr_id
from intr_fact_revenue_aggr_ccs
where volume_amount <> 0 or gross_revenue_amount <> 0 or net_revenue_amount <> 0
union all
select
    dim_client_id,
    dim_product_type_id,
    dim_source_system_id,
    dim_business_unit_id,
    dim_date_id,
    src_sys_id,
    volume_amount,
    gross_revenue_amount,
    realization_rate,
    net_revenue_amount,
    dim_provider_id,
    concat(dim_client_id,'_',dim_product_type_id,'_',dim_source_system_id,'_',dim_business_unit_id,'_',dim_date_id,'_',dim_provider_id) as src_uniq_cd,
    getdate() as row_cre_dt,
    'SFAdmin' as row_cre_usr_id,
    getdate() as row_mod_dt,
    'SFAdmin' as row_mod_usr_id
from intr_fact_revenue_aggr_pps
