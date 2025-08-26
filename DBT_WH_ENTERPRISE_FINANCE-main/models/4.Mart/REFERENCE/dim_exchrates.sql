{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_exchrates as (
        select distinct 
            a.datekey,  
	        a.DIMDATEKEY,
	        a.ACCOUNT_NAME,
            a.ACCOUNT_CODE,
            a.ROLLUP,
            a.src_uniq_cd,
            getdate() row_cre_dt,
            'SF_Admin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SF_Admin' as row_mod_usr_id
        from {{ ref("intr_dim_exchrates") }} a
    )

select * from dim_exchrates