{{ config(materialized="table", tags=["monthly"]) }}
with
    stg_ccs_cdw_client as (
        select distinct
            dimclientkey as srcclientkey,
            clid,
            clientnumber,
            clientname,
            clientparentname,
            sourcesystemid,
            lower(coalesce(c.FINANCE_PARENT, d.FINANCE_PARENT, a.financeparent)) as financeparent,
            b.act_parent_unid,
            b.act_parent_id,
            b.act_parent_name,
            b.act_unid,
            b.act_id,
            b.act_name,
            b.act_zelis_status,
            b.act_active,
            b.act_create_date,
            b.act_type,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            '1' as src_sys_id,
            concat(src_sys_id, '_', srcclientkey) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("caidwh_sources", "dimclient") }} a
        left outer join
            (
                select distinct --src_sys_id,
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
                    payor
                from {{ ref("stg_account_hierarchy") }}
                where sourcesystemcd = 'CCS'
            ) b
            on upper(concat(regexp_replace(upper(clientparentnameshort), ',', ' '), ' - ', sourcesystemclientparentbk)) = upper(b.payor)
            left outer join (select to_number(B) as CLIENT_NUMBER, case when SOURCESYSTEM = 'Compass' then 1 when SOURCESYSTEM = 'PriZem' then 3 end SOURCESYSTEM, FINANCE_PARENT, CDW_CLIENTPARENT
                             from {{ ref("stg_adaptive_cdw_financeparent_map") }} where SOURCESYSTEM in ('Compass', 'PriZem'))  c
            on (a.clientparentname = c.CDW_CLIENTPARENT or (a.CLIENTNUMBER = c.CLIENT_NUMBER and a.SOURCESYSTEMID = c.SOURCESYSTEM and substr(a.clientparentname,1,6) = substr(c.CDW_CLIENTPARENT,1,6)))
            left outer join (select BB.CLIENT_NUMBER, BB.SOURCESYSTEM, BB.FINANCE_PARENT
                             from (select B, to_number(B) as CLIENT_NUMBER, case when SOURCESYSTEM = 'Compass' then 1 when SOURCESYSTEM = 'PriZem' then 3 else -1 end SOURCESYSTEM, FINANCE_PARENT, MaxRevenueYearMonth
                                   from {{ ref("stg_adaptive_cdw_financeparent_map") }} where SOURCESYSTEM in ('Compass', 'PriZem')) BB,
                             (select B, to_number(B) as CLIENT_NUMBER_1, case when SOURCESYSTEM = 'Compass' then 1 when SOURCESYSTEM = 'PriZem' then 3 else -1 end SOURCESYSTEM_1, max(MaxRevenueYearMonth) MaxRevenueYearMonth_1
                              from {{ ref("stg_adaptive_cdw_financeparent_map") }}
                            where SOURCESYSTEM in ('Compass', 'PriZem') group by B, CLIENT_NUMBER_1, SOURCESYSTEM_1) AA
 where BB.B = AA.B and BB.SOURCESYSTEM = AA.SOURCESYSTEM_1 and BB.MaxRevenueYearMonth = AA.MaxRevenueYearMonth_1)  d
            on (a.CLIENTNUMBER = d.CLIENT_NUMBER and a.SOURCESYSTEMID = d.SOURCESYSTEM)
    )
select * from stg_ccs_cdw_client