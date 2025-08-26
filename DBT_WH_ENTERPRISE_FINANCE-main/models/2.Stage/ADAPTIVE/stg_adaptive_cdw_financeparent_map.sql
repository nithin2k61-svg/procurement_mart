{{ config(materialized="table", tags=["monthly"]) }}
with
    stg_adaptive_cdw_financeparent_map as (
select distinct client_financeparent_mapping.CLIENT,
replace(replace(replace(replace(CLIENT, ' C-0', ' '), ' C-', ' '), '- P-', '(PriZem) - '), 'ICL - Z-', 'ICL ') A, 
case when CHARINDEX('(PriZem)',A) >0 then to_varchar(try_to_numeric(replace(substr(A,CHARINDEX('(PriZem)', A)), '(PriZem) - ')))
     when CHARINDEX(' C-',CLIENT) >0 then to_varchar(try_to_numeric(replace(substr(CLIENT,(3+CHARINDEX(' C-', CLIENT))), ' C- ')))
     when CHARINDEX(' - D-',A) >0 then to_varchar(try_to_numeric(replace(substr(A, position(' - D-', A), 9), ' - D-', '')))
     when CHARINDEX(' D-',A) >0 then to_varchar(try_to_numeric(replace(substr(A, position(' D-', A), 7), ' D-', '')))
     when CHARINDEX(' Z-',CLIENT) >0 then to_varchar(try_to_numeric(replace(substr(CLIENT,(3+CHARINDEX(' Z-', CLIENT))), ' Z- ')))
      when CHARINDEX('Z-',CLIENT) >0 then to_varchar(try_to_numeric(replace(substr(CLIENT,(2+CHARINDEX('Z-', CLIENT))), ' Z- '))) end B,
case when CHARINDEX('(PriZem)',A) >0 then replace(substr(A,CHARINDEX('(PriZem)', A)), '(PriZem) - ') 
     when CHARINDEX(' C-',CLIENT) >0 then replace(substr(CLIENT,(3+CHARINDEX(' C-', CLIENT))), ' C- ') 
     when CHARINDEX(' - D-',A) >0 then  substr(A, position(' - D-', A))
     when CHARINDEX(' D-',A) >0 then  substr(A, position(' D-', A))
     when CHARINDEX(' - Z-',A) >0 then  substr(A, position(' - Z-', A))      
     when CHARINDEX('Z-',A) >0 then  substr(A, position('Z-', A)) end C,
case when CHARINDEX('Z-',CLIENT) >0 then replace (A, C, '') 
      when CHARINDEX(' D-',CLIENT) >0 then replace (A, C, concat('-',B)) else replace (A, C, B) end D,
trim(case when D is null then A else D end) CDW_ClientParent, FINANCE_PARENT, 'ACTUALS_LOAD' TYP,
case when CHARINDEX('- P-',CLIENT) >0 then 'PriZem'
     when CHARINDEX(' C-',CLIENT) >0 then 'Compass'
     when CHARINDEX(' D-',CLIENT) >0 then 'DOCS'
     when CHARINDEX('Z-',CLIENT) >0 then 'Zpass' end as SourceSystem,
     MaxRevenueYearMonth

from (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "actuals") }} a, 
{{ source("adaptive_comm_sources", "dimensions") }} d, 
{{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e
where a.CLIENT = d.DIMENSION_VALUE_NAME
and d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id
and d.ATTRIBUTE_NAME = 'Parent -Finance'
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping 

union


select distinct client_financeparent_mapping.CLIENT,
replace(replace(replace(replace(concat(trim(clients.cname),' - D-',clients.CCLIENTID,'001'), ' C-0', ' '), ' C-', ' '), '- P-', '(PriZem) - '), 'ICL - Z-', 'ICL ') A, 
case when CHARINDEX(' - D-',A) >0 then to_varchar(try_to_numeric(replace(substr(A, position(' - D-', A), 9), ' - D-', '-'))) end B,
case when CHARINDEX(' - D-',A) >0 then  substr(A, position(' - D-', A)) end C,
replace (A, C, B) D,
trim(case when D is null then A else D end) CDW_ClientParent, FINANCE_PARENT, 'DOCS_OVRD001' TYP, 'DOCS' as SourceSystem,
getdate() MaxRevenueYearMonth
from (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent
from {{ source("adaptive_comm_sources", "actuals") }} a, 
{{ source("adaptive_comm_sources", "dimensions") }} d, 
{{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e
where a.CLIENT = d.DIMENSION_VALUE_NAME
and d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id
and d.ATTRIBUTE_NAME = 'Parent -Finance'
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping inner join {{ source("ch_reference_sources", "docs_clientname_override") }} docsovrd
on (client_financeparent_mapping.CLIENT = concat(trim(docsovrd.CNAMEINZPASSTABLE),' - D-',docsovrd.CCLIENTID,'001')) inner join {{ source("docsshared_client_sources", "Clients") }}
on (docsovrd.CCLIENTID = clients.CCLIENTID)
where CHARINDEX(' - D-',A) > 0 

union 

select distinct client_financeparent_mapping.CLIENT,
replace(replace(replace(replace(concat(trim(clients.cname),' - D-',clients.CCLIENTID,'001'), ' C-0', ' '), ' C-', ' '), '- P-', '(PriZem) - '), 'ICL - Z-', 'ICL ') A, 
case when CHARINDEX(' - D-',A) >0 then to_varchar(try_to_numeric(replace(substr(A, position(' - D-', A), 9), ' - D-', '-'))) end B,
case when CHARINDEX(' - D-',A) >0 then  substr(A, position(' - D-', A)) end C,
replace (A, C, B) D,
trim(case when D is null then A else D end) CDW_ClientParent, FINANCE_PARENT, 'DOCS_OVRD000' TYP, 'DOCS' as SourceSystem,
getdate() MaxRevenueYearMonth
from (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent
from {{ source("adaptive_comm_sources", "actuals") }} a, 
{{ source("adaptive_comm_sources", "dimensions") }} d, 
{{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e
where a.CLIENT = d.DIMENSION_VALUE_NAME
and d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id
and d.ATTRIBUTE_NAME = 'Parent -Finance'
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping inner join {{ source("ch_reference_sources", "docs_clientname_override") }} docsovrd
on (client_financeparent_mapping.CLIENT = concat(trim(docsovrd.CNAMEINZPASSTABLE),' - D-',docsovrd.CCLIENTID,'000')) inner join {{ source("docsshared_client_sources", "Clients") }}
on (docsovrd.CCLIENTID = clients.CCLIENTID)
where CHARINDEX(' - D-',A) > 0 

union 

select distinct concat(trim(clients.cname),' - D-',clients.CCLIENTID,'001') as CLIENT,
replace(replace(replace(replace(concat(trim(clients.cname),' - D-',clients.CCLIENTID,'001'), ' C-0', ' '), ' C-', ' '), '- P-', '(PriZem) - '), 'ICL - Z-', 'ICL ') A, 
case when CHARINDEX(' - D-',A) >0 then to_varchar(try_to_numeric(replace(substr(A, position(' - D-', A), 9), ' - D-', '-'))) end B,
case when CHARINDEX(' - D-',A) >0 then  substr(A, position(' - D-', A)) end C,
replace (A, C, B) D,
trim(case when D is null then A else D end) CDW_ClientParent, client_financeparent_mapping.finance_parent as FINANCE_PARENT, 'DOCS_ICL' TYP, 'DOCS' as SourceSystem,
getdate() MaxRevenueYearMonth
from {{ source("ch_reference_sources", "docs_clientname_override") }} docsovrd inner join {{ source("docsshared_client_sources", "Clients") }} clients
on (docsovrd.CCLIENTID = clients.CCLIENTID) inner join (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent
from {{ source("adaptive_comm_sources", "actuals") }} a, 
{{ source("adaptive_comm_sources", "dimensions") }} d, 
{{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e
where a.CLIENT = d.DIMENSION_VALUE_NAME
and d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id
and d.ATTRIBUTE_NAME = 'Parent -Finance'
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
on (replace(trim(docsovrd.CNAMEINZPASSTABLE), 'ICL ', 'ICL - Z-') = trim(client_financeparent_mapping.CLIENT))
    )
select * from stg_adaptive_cdw_financeparent_map 