{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_source_system as (
        select distinct
            {{ source("sequence_sources", "dimsourcesystemidkey") }}.nextval
            as dim_source_system_id,
            a.sourcesystemid,
            a.sourcesystemname,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_source_system") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null
        union all
        select distinct
            b.dim_source_system_id,
            a.sourcesystemid,
            a.sourcesystemname,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_source_system") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null

        {% endif %}

        union all

        select
            -1 as dim_source_system_id,
            -1 as sourcesystemid,
            'Unknown' as sourcesystemname,
            '7' as src_sys_id,
            concat(src_sys_id, '_', sourcesystemid) as src_uniq_cd,
            getdate() row_cre_dt,
            'SF_Admin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SF_Admin' as row_mod_usr_id
    )

select *
from dim_source_system
