{{ config(materialized="table", tags=["monthly"]) }}

with
    intr_dim_exchrates as (
              select distinct
            b.datekey,
            b.DIMDATEKEY,
	        b.ACCOUNT_NAME,
            b.ACCOUNT_CODE,
            b.ROLLUP,
            b.DIMDATEKEY || '_' || b.ACCOUNT_NAME as src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            b.row_mod_dt,
            b.row_mod_usr_id from (
        select distinct
            z.datekey,
            case when e.dimdatekey is null then -1 else e.dimdatekey end DIMDATEKEY,
	        z.ACCOUNT_NAME,
            z.ACCOUNT_CODE,
            z.ROLLUP,
            z.row_cre_dt,
            z.row_cre_usr_id,
            z.row_mod_dt,
            z.row_mod_usr_id
        from {{ ref("stg_exchrates") }} z
        left outer join {{ source("caidwh_sources", "dimdate") }} e
    on (try_to_date(z.DATEKEY, 'MONYYYY') = e.dateday)   
    ) b 
    )
select * from intr_dim_exchrates