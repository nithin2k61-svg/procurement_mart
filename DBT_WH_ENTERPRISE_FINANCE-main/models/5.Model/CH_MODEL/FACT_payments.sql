{{ config(materialized="view") }}

with
    fact_payments as (
        select
            fc.dim_client_id,
            fc.dim_product_type_id,
            fc.dim_source_system_id,
            fc.dim_business_unit_id,
            fc.dim_date_id,
            to_timestamp_ntz(dd.dateday) dateday,
            pt."Product Type Group Rank" "Product Type Group ID",
            fc.ptfm_min_dt "Minimum Platform Date",
            case when pps_count = 0.000 then null else pps_count end pps_count,
            case when pps_amount = 0.000 then null else pps_amount end pps_amount,
            case
                when pps_adopt_rate = 0.000 then null else pps_adopt_rate
            end pps_adopt_rate

        from {{ ref("fact_payments_aggr") }} fc

        inner join
            {{ ref('dim_date') }} dd
            on dd.dim_date_id = fc.dim_date_id

        inner join {{ ref("DIM_product_type_ch") }} pt
            on fc.dim_product_type_id = pt.dim_product_type_id

        where dd.dateday < date_trunc('MONTH', getdate())
    )
select * from fact_payments