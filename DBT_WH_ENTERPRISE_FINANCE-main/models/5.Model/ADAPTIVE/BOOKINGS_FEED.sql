{{ config(materialized="table") }}

with bookings_feed as (
select
Case when prod."Busines Unit" = 'I&E' then 'BU0003'
when prod."Busines Unit" = 'Payments Optimization' then 'BU0002'
when prod."Busines Unit" = 'Price Optimization' then 'BU0003'
else 'BU0007' END AS Level,
REPLACE(a."Account Name",'&', '&amp;') as SF_Account_Name ,
a."Account Number" AS Salesforce_Number,
o."Opportunity Number" AS sf_Opportunity_Number, 
REPLACE(o."Name",'&', '&amp;') AS sf_Opportunity_Name,
product.PRODUCT_NAME1 as Product,
REPLACE(u."Name",'&', '&amp;') as sf_Opportunity_Owner, 
REPLACE(A."Account Type",'&', '&amp;') as account_type,
a."Vertical" as vertical,
case when o."Type of Sale" = 'Cross-Sell' then 'Cross Sell'
     when o."Type of Sale" in ('New','Upsell','Cross-Sell') then o."Type of Sale"
     ELSE  'New' end  as booking_type,
o."Probability" as Probability_Pct,
o."CloseDate" as Close_Date, 
o."Fiscal Quarter" as Fiscal_Quarter,
od."ProposedServicesACV" as total,
TO_DATE(o."CreatedDate") as CreatedDate,
o."Sales Market" as sf_sales_market,
'' as Salesforce_Parent,
bu.BUSINESS_UNIT_NAME as Business_Unit,
case when so.line_of_business__c in ('Behavioral Health','Dental','Medical','Vision','Workers Compensation','Other') 
then so.line_of_business__c else 'Other' end as Line_of_Business,
ac.PRIMARY_SEGMENT__C as Segment,
'' as notes,
--'6' as src_sys_id, 
getdate() as row_cre_dt,
'SFAdmin' as row_cre_usr_id,
getdate() as row_mod_dt,
'SFAdmin' as row_mod_usr_id
from {{source('adaptive_model_sources','FACTOPPORTUNITY')}} o
inner join {{source('adaptive_model_sources','FACTOPPORTUNITYDETAIL')}} od on od."OpportunityId" = o."Id"
inner join {{source('adaptive_model_sources','DIMPROPOSEDSERVICES')}} prod on prod."Proposed Services"= od."Proposed Services"
inner join {{source('adaptive_model_sources','DIMACCOUNTS')}} a on o."AccountId"=a."AccountId"
left outer join {{source('adaptive_model_sources','DIMACCOUNTS')}} a1 on a."ParentId"=a1."AccountId"
inner join {{source('adaptive_model_sources','DIMUSER')}} u on o."OwnerId" =u."UserID"
inner join {{source('salesforce_sources','account')}} ac on ac."ACCOUNT_ID__C"=a."Account Number"
inner join {{source('salesforce_sources','OPPORTUNITY')}} so on so.OPPORTUNITY_NUMBER__C = o."Opportunity Number"
left outer join {{source('adaptive_comm_sources','BOOKING_WORKDAY_PRODUCT_MAPPING')}} BWPM on prod."Proposed Services"= BWPM.SALESFORCE_PROPOSEDSERVICES
left outer join {{source('adaptive_comm_sources','product')}} product on bwpm.PRODUCT_NUMBER = TRIM(substr(product.product_name1,0,CHARINDEX(' ',product.product_name1)))
left outer join {{source('adaptive_comm_sources','business_unit')}} bu ON 
(Case when prod."Busines Unit" = 'I&E' then 'BU0003'
when prod."Busines Unit" = 'Payments Optimization' then 'BU0002'
when prod."Busines Unit" = 'Price Optimization' then 'BU0003'
else 'BU0007' END) = TRIM(substr(bu.BUSINESS_UNIT_NAME,0,CHARINDEX(' ',bu.BUSINESS_UNIT_NAME)))
where "CloseDate" like '2024%' and "Stage Name" = 'Closed/Won' 
and COALESCE("Type of Sale", '') != 'Renewal' 
and o."RecordTypeId" in ('0124V000001SkaQQAS','0124V000001apuoQAA','0124V000001apupQAA') 
order by 3
)
select * from bookings_feed