{{ config(materialized="table", tags=["daily"]) }}

with
    locations_from_po as (
        select distinct
            LOCATION,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where LOCATION is not null
    ),
    
    all_locations as (
        select * from locations_from_po
    ),

    intr_dim_location as (
        select distinct
            LOCATION as LOCATION_CODE,
            LOCATION as LOCATION_NAME,
            -- Extract region from location if follows pattern
            case 
                when upper(LOCATION) like '%US%' or upper(LOCATION) like '%AMERICA%' then 'North America'
                when upper(LOCATION) like '%EU%' or upper(LOCATION) like '%EUROPE%' then 'Europe'
                when upper(LOCATION) like '%ASIA%' or upper(LOCATION) like '%APAC%' then 'Asia Pacific'
                when upper(LOCATION) like '%UK%' or upper(LOCATION) like '%BRITAIN%' then 'United Kingdom'
                when upper(LOCATION) like '%CANADA%' or upper(LOCATION) like '%CA%' then 'Canada'
                else 'Other'
            end as LOCATION_REGION,
            case 
                when upper(LOCATION) like '%HQ%' or upper(LOCATION) like '%HEADQUARTERS%' then 'Headquarters'
                when upper(LOCATION) like '%BRANCH%' or upper(LOCATION) like '%OFFICE%' then 'Branch Office'
                when upper(LOCATION) like '%WAREHOUSE%' or upper(LOCATION) like '%DC%' then 'Distribution Center'
                else 'Standard Location'
            end as LOCATION_TYPE,
            src_sys_id,
            concat(src_sys_id, '_', LOCATION) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_locations
    )

select *
from intr_dim_location