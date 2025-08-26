{{ config(materialized="table", tags=["daily"]) }}

with
    projects_from_po as (
        select distinct
            PROJECT,
            '2' as src_sys_id
        from {{ ref("stg_purchase_orders") }}
        where PROJECT is not null
    ),
    
    all_projects as (
        select * from projects_from_po
    ),

    intr_dim_project as (
        select distinct
            PROJECT as PROJECT_CODE,
            PROJECT as PROJECT_NAME,
            -- Extract project type from project name if follows pattern
            case 
                when upper(PROJECT) like '%IT%' or upper(PROJECT) like '%TECH%' or upper(PROJECT) like '%SYSTEM%' then 'IT/Technology'
                when upper(PROJECT) like '%CONSTRUCTION%' or upper(PROJECT) like '%BUILD%' then 'Construction'
                when upper(PROJECT) like '%MARKETING%' or upper(PROJECT) like '%CAMPAIGN%' then 'Marketing'
                when upper(PROJECT) like '%RESEARCH%' or upper(PROJECT) like '%R&D%' then 'Research & Development'
                when upper(PROJECT) like '%TRAINING%' or upper(PROJECT) like '%EDUCATION%' then 'Training'
                when upper(PROJECT) like '%MAINTENANCE%' or upper(PROJECT) like '%REPAIR%' then 'Maintenance'
                else 'General'
            end as PROJECT_TYPE,
            case 
                when upper(PROJECT) like '%ACTIVE%' or upper(PROJECT) like '%ONGOING%' then 'Active'
                when upper(PROJECT) like '%COMPLETE%' or upper(PROJECT) like '%CLOSED%' then 'Completed'
                when upper(PROJECT) like '%HOLD%' or upper(PROJECT) like '%PAUSE%' then 'On Hold'
                else 'Unknown'
            end as PROJECT_STATUS,
            src_sys_id,
            concat(src_sys_id, '_', PROJECT) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from all_projects
    )

select *
from intr_dim_project