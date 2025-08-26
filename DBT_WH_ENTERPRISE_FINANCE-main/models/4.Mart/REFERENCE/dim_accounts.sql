{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns"
    )
}}

with dim_accounts as (
    select
        {{ source('reference_sequences', 'dimaccountskey') }}.nextval as dim_accounts_id,
		A.account_name1,
        A.account_name2,
        A.account_name3,
        A.account_name4,
        A.account_name5,
        A.sourcesystemid,
	    A.SRC_UNIQ_CD,
	    A.DEL_INDC,
        A.row_cre_dt,
        A.row_cre_usr_id,
        A.row_mod_dt,
        A.row_mod_usr_id
    from {{ ref('intr_dim_accounts') }} A
    {% if is_incremental() %}
    left join {{ this }} B on A.SRC_UNIQ_CD = B.SRC_UNIQ_CD
    where B.SRC_UNIQ_CD is null

    UNION ALL

    select
		B.dim_accounts_id,
        A.account_name1,
        A.account_name2,
        A.account_name3,
        A.account_name4,
        A.account_name5,
        A.sourcesystemid,
	    A.SRC_UNIQ_CD,
	    A.DEL_INDC,
        B.row_cre_dt,
        B.row_cre_usr_id,
        A.row_mod_dt,
        A.row_mod_usr_id
    from {{ ref('intr_dim_accounts') }} A
    left join {{ this }} B on A.SRC_UNIQ_CD = B.SRC_UNIQ_CD
    where B.SRC_UNIQ_CD is not null
    {% endif %}
)
select * from dim_accounts