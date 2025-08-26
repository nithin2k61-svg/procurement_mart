{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_location as (
        select
            {{ source("sequence_sources", "dimlocationidkey") }}.nextval as dim_location_id,
            a.LOCATION_CODE,
            a.LOCATION_NAME,
            a.LOCATION_REGION,
            a.LOCATION_TYPE,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_location") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select
            b.dim_location_id,
            a.LOCATION_CODE,
            a.LOCATION_NAME,
            a.LOCATION_REGION,
            a.LOCATION_TYPE,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_location") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}

        union all

        select
            -1 as dim_location_id,
            'Unknown' as LOCATION_CODE,
            'Unknown' as LOCATION_NAME,
            'Unknown' as LOCATION_REGION,
            'Unknown' as LOCATION_TYPE,
            '1' as src_sys_id,
            concat(src_sys_id, '_', 'Unknown') as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select *
from dim_location