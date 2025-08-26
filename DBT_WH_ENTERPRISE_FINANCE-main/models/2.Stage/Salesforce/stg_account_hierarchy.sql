{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_account_hierarchy as (
        select
            act_parent_unid,
            act_parent_id,
            act_parent_name,
            act_unid,
            t1.act_id,
            pyr.payor,
            pyr.payor_id,
            pyr.sourcesystemcd,
            act_name,
            act_zelis_status,
            to_varchar(act_active) as act_active,
            to_varchar(act_create_date) as act_create_date,
            act_type,
            team_sr_ccs,
            team_sr_pps,
            team_sr_com,
            team_am_ccs,
            team_am_pps,
            team_am_def,
            '8' as src_sys_id,
            concat(src_sys_id, '_', t1.act_id, '_', pyr.payor, '_', pyr.sourcesystemcd) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from
            (
                select
                    apid.act_parent_unid,
                    apid.act_parent_id,
                    apid.act_parent_name,
                    nvl(acid.act_unid, apid.act_parent_unid) as act_unid,
                    nvl(acid.act_id, apid.act_parent_id) as act_id,
                    nvl(acid.act_name, apid.act_parent_name) as act_name,
                    nvl(
                        acid.act_zelis_status, apid.act_parent_zelis_status
                    ) as act_zelis_status,
                    nvl(acid.act_active, apid.act_parent_active) as act_active,
                    nvl(
                        acid.act_create_date, apid.act_parent_create_date
                    ) as act_create_date,
                    case
                        when apid.act_type = 'Health Plan & TPA'
                        then 'Health Plan'
                        else apid.act_type
                    end as act_type,
                    apid.team_sr_ccs,
                    apid.team_sr_pps,
                    apid.team_sr_com,
                    apid.team_am_ccs,
                    apid.team_am_pps,
                    apid.team_am_def
                from
                    (
                        select
                            a.id as act_parent_unid,
                            a.account_id__c as act_parent_id,
                            a.name as act_parent_name,
                            a.zelis_status__c as act_parent_zelis_status,
                            a.active_acct__c as act_parent_active,
                            a.type as act_type,
                            a.createddate as act_parent_create_date,
                            a.ownerid as team_sr_ccs,
                            usr1.name as team_sr_ccs2,
                            a.coowner__c as team_sr_pps,
                            a.communications_owner__c as team_sr_com,
                            a.Price_Client_Manager__c as team_am_ccs,
                            a.payments_client_manager__c as team_am_pps,
                            null as team_am_def
                        from {{ source("salesforce_sources", "account") }} as a
                        left join
                            {{ source("salesforce_sources", "user") }} as usr1
                            on (usr1.id = a.ownerid)
                        left join
                            {{ source("salesforce_sources", "user") }} as usr2
                            on (usr2.id = a.coowner__c)
                        left join
                            {{ source("salesforce_sources", "user") }} as usr3
                            on (usr3.id = a.communications_owner__c)
                        where parentid is null
                    ) as apid
                left join
                    (
                        select
                            parentid as act_parent_unid,
                            id as act_unid,
                            account_id__c as act_id,
                            name as act_name,
                            zelis_status__c as act_zelis_status,
                            active_acct__c as act_active,
                            createddate as act_create_date
                        from {{ source("salesforce_sources", "account") }}
                        where parentid is not null
                        union all
                        select distinct
                            id as act_parent_unid,
                            id as act_unid,
                            account_id__c as act_id,
                            name as act_name,
                            zelis_status__c as act_zelis_status,
                            active_acct__c as act_active,
                            createddate as act_create_date
                        from {{ source("salesforce_sources", "account") }}
                        where
                            id in (
                                select distinct parentid
                                from {{ source("salesforce_sources", "account") }}
                                where parentid is not null
                            )
                    ) as acid
                    on (acid.act_parent_unid = apid.act_parent_unid)
            ) as t1
        left join
            (
                select distinct act_id, payor, payor_id, sourcesystemcd
                from
                    (
                        select
                            act_id,
                            payor,
                            case
                                when upper(product) = 'OON'
                                then 'OON'
                                when upper(product) = 'CLAIMS EDITING'
                                then 'EDITING'
                                when upper(product) = 'HOSPITAL BILL REVIEW'
                                then 'BILL REVIEW & AUDIT'
                                when upper(product) in ('ERS', 'MPS')
                                then 'OON'
                                when
                                    upper(product_subgroup) in ('SELECT','SELECT PLUS','FAX','DOWNLOAD','VRA CARD')
                                then 'VCC'
                                when upper(product_subgroup) in ('DIRECT ACH')
                                then 'ACH+'
                                when upper(product_subgroup) in ('PAYER FEE ACH')
                                then 'PAYERSPONSORED'
                                when
                                    upper(product_subgroup)
                                    in ('CHECK PRINTING SERVICES', 'PRINT')
                                then 'CHECK'
                                when upper(product) in ('CHECK/EOB', 'ID CARDS')
                                then upper(product)
                                else null
                            end as product_grp,
                            case
                                when
                                    upper(product_grp)
                                    in ('BILL REVIEW & AUDIT', 'OON', 'EDITING')
                                    and upper(trim(payor)) regexp '.* .*'
                                then
                                    regexp_substr(
                                        payor, '^(.+?)( )(\\d*)$', 1, 1, 'm', 3
                                    )
                                when
                                    upper(product_grp) in ('VCC','ACH+','PAYERSPONSORED','PAYERBRANDEDVCC','CHECK')
                                then
                                    regexp_substr(
                                        payor, '^(.+?)( )(\\d*)$', 1, 1, 'm', 3
                                    )
                                when upper(product_grp) in ('CHECK/EOB', 'ID CARDS')
                                then
                                    regexp_substr(
                                        payor, '^(.+?)( )(\\d*)$', 1, 1, 'm', 3
                                    )
                                else null
                            end as payor_id,
                            case
                                when
                                    upper(product_grp)
                                    in ('BILL REVIEW & AUDIT', 'OON', 'EDITING')
                                then 'CCS'
                                when
                                    upper(product_grp) in ('VCC','ACH+','PAYERSPONSORED','PAYERBRANDEDVCC','CHECK')
                                then 'PPS'
                                when upper(product_grp) in ('CHECK/EOB', 'ID CARDS')
                                then 'DOCS'
                                else null
                            end as sourcesystemcd
                        from
                            {{
                                source(
                                    "ch_reference_sources", "ACCOUNT_PAYER_MAPPING"
                                )
                            }}
                    )
                where payor_id is not null
            ) pyr
            on t1.act_id = pyr.act_id
    )
select *
from stg_account_hierarchy
