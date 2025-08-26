{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_business_unit as (
        select distinct
            {{ source("sequence_sources", "dimbusinessunitidkey") }}.nextval
            as dim_business_unit_id,
            a.businessunitid,
            a.businessunitname,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_business_unit") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select distinct
            b.dim_business_unit_id,
            a.businessunitid,
            a.businessunitname,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_business_unit") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null

        {% endif %}
    )

select *
from dim_business_unit
