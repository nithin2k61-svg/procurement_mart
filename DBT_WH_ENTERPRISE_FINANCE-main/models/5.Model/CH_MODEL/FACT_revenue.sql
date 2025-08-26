{{ config(materialized="view") }}

with
    fact_revenue as (
        select
            fc.dim_client_id,
            fc.dim_product_type_id,
            fc.dim_source_system_id,
            fc.dim_business_unit_id,
            fc.dim_date_id,
            to_timestamp_ntz(dd.dateday) dateday,
            pt."Product Type Group Rank" "Product Type Group ID",
            case when volume_amount = 0.000 then null else volume_amount end volume,
            case
                when gross_revenue_amount = 0.000 then null else gross_revenue_amount
            end grossrevenue,
            case
                when net_revenue_amount = 0.000 then null else net_revenue_amount
            end netrevenue

        from {{ ref("fact_revenue_aggr") }} fc

        inner join
            {{ ref('dim_date') }} dd
            on dd.dim_date_id = fc.dim_date_id

        inner join {{ ref("DIM_product_type_ch") }} pt
            on fc.dim_product_type_id = pt.dim_product_type_id

        where dd.dateday < date_trunc('MONTH', getdate())
    )
select * from fact_revenue