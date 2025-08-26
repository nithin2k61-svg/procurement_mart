{{ config(materialized="view") }}

with
    dim_client_ch as (
        select
            dim_client_id,
            clid "Payor ID",
            clientnumber "Payor Number",
            clientname "Payor Name",
            sourcesystemid "Source System ID",
            account_id "Account Child ID",
            account_name "Account Child Name",
            account_parent_id "Account Parent ID",
            account_parent_name "Account Parent Name",
            account_status "Account Status",
            account_actv_indc "Account Active Flag",
            c.act_type "Account Type",
            u1."Name" "CCS Sales Representative",
            u2."Name" "PPS Sales Representative",
            u3."Name" "Communications Sales Representative",
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) salesrepjoin,
            c.team_am_ccs "CCS Strategic Account Manager",
            c.team_am_pps "PPS Strategic Account Manager",
            c.team_am_def "Communications Account Manager",
            concat(to_varchar(c.team_am_ccs), '-', to_varchar(c.team_am_pps), '-', to_varchar(c.team_am_def)) accountmgrjoin,
            src_sys_id "Platform ID",
            concat('https://zelis.lightning.force.com/lightning/r/Account/', to_varchar(left(act_parent_unid, length(act_parent_unid) - 3)), '/view') SALESFORCEURL
        from {{ ref("dim_client") }} c
        left join
            {{ source("ads_reporting_sources", "dimuser") }} u1
            on c.team_sr_ccs = u1."UserID"
        left join
            {{ source("ads_reporting_sources", "dimuser") }} u2
            on c.team_sr_pps = u2."UserID"
        left join
            {{ source("ads_reporting_sources", "dimuser") }} u3
            on c.team_sr_com = u3."UserID"
    )
select * from dim_client_ch