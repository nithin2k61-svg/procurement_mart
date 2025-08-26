{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_spend_category as (
        select
            {{ source("sequence_sources", "dimspendcategoryidkey") }}.nextval as dim_spend_category_id,
            a.SPEND_CATEGORY_CODE,
            a.SPEND_CATEGORY_NAME,
            a.SPEND_CATEGORY_GROUP,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_spend_category") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select
            b.dim_spend_category_id,
            a.SPEND_CATEGORY_CODE,
            a.SPEND_CATEGORY_NAME,
            a.SPEND_CATEGORY_GROUP,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_spend_category") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}

        union all

        select
            -1 as dim_spend_category_id,
            'Unknown' as SPEND_CATEGORY_CODE,
            'Unknown' as SPEND_CATEGORY_NAME,
            'Unknown' as SPEND_CATEGORY_GROUP,
            '1' as src_sys_id,
            concat(src_sys_id, '_', 'Unknown') as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select *
from dim_spend_category