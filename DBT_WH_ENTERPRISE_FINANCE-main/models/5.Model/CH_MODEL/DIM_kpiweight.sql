{{ config(materialized="view") }}

with
    dim_kpiweight as (
        select
            kpi.chd_kpi_id as kpi_id,
            chd_kpi_label as "KPI Label",
            met.chd_metric as "Metric",
            chd_metric_weight / 100 as "Weight"
        from {{ source("ads_reporting_sources", "DIM_CH_KPI") }} kpi
        join
            {{ source("ads_reporting_sources", "DIM_CH_KPI_MAP") }} map
            on map.chd_kpi_id = kpi.chd_kpi_id
        join
            {{ source("ads_reporting_sources", "DIM_CH_SCORE_METRIC") }} met
            on map.chd_metric_id = met.chd_metric_id
        where chd_metric_grp = 1
    )
select *
from dim_kpiweight
