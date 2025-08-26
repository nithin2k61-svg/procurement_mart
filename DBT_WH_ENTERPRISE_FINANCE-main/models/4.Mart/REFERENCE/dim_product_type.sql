{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_product_type as (
        select distinct
            {{ source("sequence_sources", "dimproducttypeidkey") }}.nextval
            as dim_product_type_id,
            a.product,
            a.product_type,
            a.product_type_group,
            a.product_type_category,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_product_type") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select distinct
            b.dim_product_type_id,
            a.product,
            a.product_type,
            a.product_type_group,
            a.product_type_category,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_product_type") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null

        {% endif %}

        union all
        select
            -1 as dim_product_type_id,
            'Unknown' as product,            
            'Unknown' as product_type,
            'Unknown' as product_type_group,
            'Unknown' as product_type_category,
            '7' as src_sys_id,
            concat(src_sys_id, '_', product_type) as src_uniq_cd,
            getdate() row_cre_dt,
            'SF_Admin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SF_Admin' as row_mod_usr_id
    )

select *
from dim_product_type
