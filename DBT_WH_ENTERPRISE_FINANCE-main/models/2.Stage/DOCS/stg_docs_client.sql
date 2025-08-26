{{ config(materialized="table", tags=["monthly"]) }}
with
    stg_docs_client as (
        select distinct
            to_varchar(a.cclientid) as srcclientkey,			
			 null as clid,
            a.cclientid AS clientnumber,
             trim(a.cname) || '-' || a.cclientid as clientname,   
            coalesce(cfm.FINANCE_PARENT, d.FINANCE_PARENT, trim(a.cname)) as clientparentname,
            null sourcesystemid,
            lower(coalesce(c.FINANCE_PARENT, d.FINANCE_PARENT, trim(a.cname))) as financeparent,
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
            '3' as src_sys_id,
            concat(src_sys_id, '_', a.cclientid) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("docsshared_client_sources", "Clients") }} a
        left outer join
            (
                select distinct
                    --src_sys_id,
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
                    payor,
                    payor_id
                from {{ ref("stg_account_hierarchy") }}
                where sourcesystemcd = 'DOCS'
            ) b
            on a.cclientid = b.payor_id
           left outer join (select distinct  CLIENT, SOURCESYSTEM, FINANCE_PARENT, CDW_CLIENTPARENT
                             from {{ ref("stg_adaptive_cdw_financeparent_map") }} where SOURCESYSTEM in ('DOCS'))  c
            on (clientname = c.CDW_CLIENTPARENT )
            left outer join (select BB.CLIENT_NUMBER, BB.SOURCESYSTEM, BB.FINANCE_PARENT
                             from (select B, to_number(B) as CLIENT_NUMBER, SOURCESYSTEM, FINANCE_PARENT, MaxRevenueYearMonth
                                   from {{ ref("stg_adaptive_cdw_financeparent_map") }} where SOURCESYSTEM in ('DOCS')) BB,
                             (select B, to_number(B) as CLIENT_NUMBER_1, SOURCESYSTEM as SOURCESYSTEM_1, max(MaxRevenueYearMonth) MaxRevenueYearMonth_1
                              from {{ ref("stg_adaptive_cdw_financeparent_map") }}
                            where SOURCESYSTEM in ('DOCS') group by B, CLIENT_NUMBER_1, SOURCESYSTEM_1) AA
 where BB.B = AA.B and BB.SOURCESYSTEM = AA.SOURCESYSTEM_1 and BB.MaxRevenueYearMonth = AA.MaxRevenueYearMonth_1)  d
            on (a.cclientid = d.CLIENT_NUMBER)
            left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
            on lower(trim(cfm.client)) = lower(trim(c.client)) 
            where a.cclientid not in ('B001', 'B002','B003')  
    )
select *
from stg_docs_client
