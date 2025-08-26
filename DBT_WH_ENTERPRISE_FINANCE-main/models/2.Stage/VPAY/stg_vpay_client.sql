
{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_vpay_client as (
        select distinct
            to_varchar(ssavpayrev.client_number) as srcclientkey,
            null as clid,
            ssavpayrev.client_number as clientnumber,
            trim(ssavpayrev.client_name)  || '-' || ssavpayrev.client_number as clientname,
            coalesce(cfm.FINANCE_PARENT, d.FINANCE_PARENT, trim(ssavpayrev.client_name)) as clientparentname,
            null sourcesystemid,
            lower(coalesce(c.FINANCE_PARENT, d.FINANCE_PARENT, trim(ssavpayrev.client_name))) as financeparent,
            '5' as src_sys_id,
            concat(src_sys_id, '_', ssavpayrev.client_number) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("saasvpay_client_sources", "saasvpay_revenue") }} ssavpayrev
           left outer join (select DISTINCT CLIENT, SOURCESYSTEM, FINANCE_PARENT, CDW_CLIENTPARENT
                             from {{ ref("stg_adaptive_cdw_financeparent_map") }} where SOURCESYSTEM in ('DOCS'))  c
            on (CLIENTNAME = c.CDW_CLIENTPARENT )
            left outer join (select BB.CLIENT_NUMBER, BB.SOURCESYSTEM, BB.FINANCE_PARENT
                             from (select B, to_number(B) as CLIENT_NUMBER, SOURCESYSTEM, FINANCE_PARENT, MaxRevenueYearMonth
                                   from {{ ref("stg_adaptive_cdw_financeparent_map") }} where SOURCESYSTEM in ('DOCS')) BB,
                             (select B, to_number(B) as CLIENT_NUMBER_1, SOURCESYSTEM as SOURCESYSTEM_1, max(MaxRevenueYearMonth) MaxRevenueYearMonth_1
                              from {{ ref("stg_adaptive_cdw_financeparent_map") }}
                            where SOURCESYSTEM in ('DOCS') group by B, CLIENT_NUMBER_1, SOURCESYSTEM_1) AA
 where BB.B = AA.B and BB.SOURCESYSTEM = AA.SOURCESYSTEM_1 and BB.MaxRevenueYearMonth = AA.MaxRevenueYearMonth_1)  d
        on (ssavpayrev.CLIENT_NUMBER = d.CLIENT_NUMBER)
        left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
        on lower(trim(cfm.client)) = lower(trim(c.client)) 
        where client_source_system = 'VPAY' 
    )
select *
from stg_vpay_client
