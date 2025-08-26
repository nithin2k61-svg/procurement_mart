{{ config(materialized="table", tags=["monthly"]) }}

with
    intr_dim_client as (

        select distinct
            srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            financeparent,
            act_parent_unid,
            act_parent_id as account_parent_id,
            act_parent_name as account_parent_name,
            act_unid,
            act_id as account_id,
            act_name as account_name,
            act_zelis_status as account_status,
            act_active as account_actv_indc,
            act_create_date,
            act_type,
            team_sr_ccs,
            team_sr_pps,
            team_sr_com,
            team_am_ccs,
            team_am_pps,
            team_am_def,
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_ccs_cdw_client") }}

        union

        select distinct
            srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            financeparent,
            act_parent_unid,
            act_parent_id as account_parent_id,
            act_parent_name as account_parent_name,
            act_unid,
            act_id as account_id,
            act_name as account_name,
            act_zelis_status as account_status,
            act_active as account_actv_indc,
            act_create_date,
            act_type,
            team_sr_ccs,
            team_sr_pps,
            team_sr_com,
            team_am_ccs,
            team_am_pps,
            team_am_def,
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_pps_ppswh_client") }}

        union

        select distinct
            srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            financeparent,
            act_parent_unid,
            act_parent_id,
            act_parent_name,
            act_unid,
            act_id,
            act_name,
            act_zelis_status,
            act_active,
            act_create_date,
            act_type,
            team_sr_ccs,
            team_sr_pps,
            team_sr_com,
            team_am_ccs,
            team_am_pps,
            team_am_def,
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_adaptive_client") }}

        union

        select distinct
            srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            financeparent,
            act_parent_unid,
            act_parent_id as account_parent_id,
            act_parent_name as account_parent_name,
            act_unid,
            act_id as account_id,
            act_name as account_name,
            act_zelis_status as account_status,
            act_active as account_actv_indc,
            act_create_date,
            act_type,
            team_sr_ccs,
            team_sr_pps,
            team_sr_com,
            team_am_ccs,
            team_am_pps,
            team_am_def,
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_docs_client") }}

        union

        select distinct
            srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            financeparent,
            null as act_parent_unid,
            null as account_parent_id,
            null as account_parent_name,
            null as act_unid,
            null as account_id,
            null as account_name,
            null as account_status,
            null as account_actv_indc,
            null as act_create_date,
            null as act_type,
            null as team_sr_ccs,
            null as team_sr_pps,
            null as team_sr_com,
            null as team_am_ccs,
            null as team_am_pps,
            null as team_am_def,
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_vpay_client") }}

        union

        select distinct
            srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            financeparent,
            null as act_parent_unid,
            null as account_parent_id,
            null as account_parent_name,
            null as act_unid,
            null as account_id,
            null as account_name,
            null as account_status,
            null as account_actv_indc,
            null as act_create_date,
            null as act_type,
            null as team_sr_ccs,
            null as team_sr_pps,
            null as team_sr_com,
            null as team_am_ccs,
            null as team_am_pps,
            null as team_am_def,
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_saas_client") }}

    )
select *
from intr_dim_client
