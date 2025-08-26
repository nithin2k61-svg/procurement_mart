{{ config(materialized="view") }}

with
    fact_budgets as (
        select
            fb.dim_client_id,
            fb.dim_product_type_id,
            fb.dim_source_system_id,
            fb.dim_business_unit_id,
            fb.dim_date_id,
            to_timestamp_ntz(dd.dateday) dateday,
            pt."Product Type Group Rank" "Product Type Group ID",
            fb.ptfm_min_dt "Minimum Platform Date",
            case
                when rev_plan_plan = 0.000 then null else rev_plan_plan
            end budgetamount

        from {{ ref("fact_budgets_aggr") }} fb

        inner join
            {{ ref('dim_date') }} dd
            on dd.dim_date_id = fb.dim_date_id
        inner join {{ ref("DIM_product_type_ch") }} pt
            on fb.dim_product_type_id = pt.dim_product_type_id
        where dd.dateday < date_trunc('MONTH', getdate())
    )
select * from fact_budgets