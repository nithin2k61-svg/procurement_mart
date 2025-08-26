{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_client as (
        select
            {{ source("sequence_sources", "dimclientidkey") }}.nextval as dim_client_id,
            a.srcclientkey,
            a.clid,
            a.clientnumber,
            a.clientname,
            a.clientparentname,
            a.sourcesystemid,
            a.financeparent,
            a.act_parent_unid,
            a.account_parent_id,
            a.account_parent_name,
            a.act_unid,
            a.account_id,
            a.account_name,
            a.account_status,
            a.account_actv_indc,
            a.act_create_date,
            a.act_type,
            a.team_sr_ccs,
            a.team_sr_pps,
            a.team_sr_com,
            a.team_am_ccs,
            a.team_am_pps,
            a.team_am_def,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_client") }} a

        {% if is_incremental() %}

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select
            b.dim_client_id,
            a.srcclientkey,
            a.clid,
            a.clientnumber,
            a.clientname,
            a.clientparentname,
            a.sourcesystemid,
            a.financeparent,
            a.act_parent_unid,
            a.account_parent_id,
            a.account_parent_name,
            a.act_unid,
            a.account_id,
            a.account_name,
            a.account_status,
            a.account_actv_indc,
            a.act_create_date,
            a.act_type,
            a.team_sr_ccs,
            a.team_sr_pps,
            a.team_sr_com,
            a.team_am_ccs,
            a.team_am_pps,
            a.team_am_def,
            a.src_sys_id,
            a.src_uniq_cd,
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_client") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}

        union all

        select
            -1 as dim_client_id,
            -1 as srcclientkey,
            -1 as clid,
            -1 as clientnumber,
            'Unknown' as clientname,
            'Unknown' as clientparentname,
            -1 as sourcesystemid,
            'Unknown' as financeparent,
            'Unknown' as act_parent_unid,
            'Unknown' as account_parent_id,
            'Unknown' as account_parent_name,
            'Unknown' as act_unid,
            'Unknown' as account_id,
            'Unknown' as account_name,
            'Unknown' as account_status,
            'Unknown' as account_actv_indc,
            'Unknown' as act_create_date,
            'Unknown' as act_type,
            'Unknown' as team_sr_ccs,
            'Unknown' as team_sr_pps,
            'Unknown' as team_sr_com,
            'Unknown' as team_am_ccs,
            'Unknown' as team_am_pps,
            'Unknown' as team_am_def,
            '7' as src_sys_id,
            concat(src_sys_id, '_', srcclientkey) as src_uniq_cd,
            getdate() row_cre_dt,
            'SF_Admin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SF_Admin' as row_mod_usr_id
    )

select *
from dim_client
