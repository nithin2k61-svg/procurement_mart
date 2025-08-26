{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_comms_aggr as (
        select
            dcs.payor_id as client,
            dcs.ptfm_min_dt as ptfm_min_dt,
            monthdate.dateday as tranyearmonthdate,
            dcs.product_type as producttype,
            3 as src_sys_id,
            '3' as businessunit,
            concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            sum(dcs.dcs_count_imp) as dcs_count_imp,
            sum(dcs.dcs_count_prt) as eob_count_prt,
            case
                when sum(dcs.dcs_count_imp) > 0
                then
                    (
                        (sum(dcs.dcs_count_imp) - sum(dcs.dcs_count_prt))
                        / sum(dcs.dcs_count_imp)
                    )
                else 0
            end as doc_elim_rate
        from
            (
                select
                    payer_id as payor_id,
                    ptfm_min_dt_idc as ptfm_min_dt,
                    dimdate as dateday,
                    'Enrollment-Product' as product_type,
                    idc_count as dcs_count_imp,
                    idc_count as dcs_count_prt
                from {{ source("ch_reference_sources", "CHD_RAW_DCS_DATA") }}
                where idc_count > 0

                union all

                select
                    payer_id as payor_id,
                    ptfm_min_dt_eob as ptfm_min_dt,
                    dimdate as dateday,
                    'Communication-Product' as product_type,
                    eob_count_imp as dcs_count_imp,
                    eob_count_prt as dcs_count_prt
                from {{ source("ch_reference_sources", "CHD_RAW_DCS_DATA") }}
                where eob_count_imp > 0
            ) as dcs
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(dcs.dateday)) + 1), dcs.dateday)
                = monthdate.dateday
            )
        where tranyearmonthdate >= date_trunc('YEAR', dateadd(year, -4, getdate()))
        group by
            client,
            ptfm_min_dt,
            tranyearmonthdate,
            producttype,
            src_sys_id,
            businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit
    )
select *
from stg_comms_aggr
