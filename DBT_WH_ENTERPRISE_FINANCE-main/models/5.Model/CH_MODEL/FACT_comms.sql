{{ config(materialized="view") }}

with
    fact_comms as (
        select
            fc.dim_client_id,
            fc.dim_product_type_id,
            fc.dim_source_system_id,
            fc.dim_business_unit_id,
            fc.dim_date_id,
            to_timestamp_ntz(dd.dateday) dateday,
            pt."Product Type Group Rank" "Product Type Group ID",
            fc.ptfm_min_dt "Minimum Platform Date",
            case
                when dcs_count_imp = 0.000 then null else dcs_count_imp
            end dcs_count_imp,
            case
                when eob_count_prt = 0.000 then null else eob_count_prt
            end eob_count_prt

        from {{ ref("fact_comms_aggr") }} fc

        inner join
            {{ ref('dim_date') }} dd
            on dd.dim_date_id = fc.dim_date_id

        inner join {{ ref("DIM_product_type_ch") }} pt
            on fc.dim_product_type_id = pt.dim_product_type_id

        where dd.dateday < date_trunc('MONTH', getdate())
    )
select * from fact_comms