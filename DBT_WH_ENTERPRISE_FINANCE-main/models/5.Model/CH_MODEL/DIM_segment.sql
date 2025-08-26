{{ config(materialized="view") }}

with
    dim_segment as (
        select segmentnm "Segment", segmentll "Segment From", segmentul "Segment To"
        from {{ source("ads_reporting_sources", "DIM_SEGMENT") }}
        where segmentbu = 'Multiple'
    )
select *
from dim_segment
