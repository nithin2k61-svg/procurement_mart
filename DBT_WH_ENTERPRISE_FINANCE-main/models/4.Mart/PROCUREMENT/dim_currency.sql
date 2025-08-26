{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_currency as (
        select
            {{ source("sequence_sources", "dimcurrencyidkey") }}.nextval as dim_currency_id,
            a.CURRENCY_CODE,
            a.CURRENCY_NAME,
            a.CURRENCY_TYPE,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_currency") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select
            b.dim_currency_id,
            a.CURRENCY_CODE,
            a.CURRENCY_NAME,
            a.CURRENCY_TYPE,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_currency") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}

        union all

        select
            -1 as dim_currency_id,
            'Unknown' as CURRENCY_CODE,
            'Unknown' as CURRENCY_NAME,
            'Unknown' as CURRENCY_TYPE,
            '1' as src_sys_id,
            concat(src_sys_id, '_', 'Unknown') as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select *
from dim_currency