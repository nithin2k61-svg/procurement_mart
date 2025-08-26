{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_project as (
        select
            {{ source("sequence_sources", "dimprojectidkey") }}.nextval as dim_project_id,
            a.PROJECT_CODE,
            a.PROJECT_NAME,
            a.PROJECT_TYPE,
            a.PROJECT_STATUS,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_project") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select
            b.dim_project_id,
            a.PROJECT_CODE,
            a.PROJECT_NAME,
            a.PROJECT_TYPE,
            a.PROJECT_STATUS,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_project") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}

        union all

        select
            -1 as dim_project_id,
            'Unknown' as PROJECT_CODE,
            'Unknown' as PROJECT_NAME,
            'Unknown' as PROJECT_TYPE,
            'Unknown' as PROJECT_STATUS,
            '1' as src_sys_id,
            concat(src_sys_id, '_', 'Unknown') as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select *
from dim_project