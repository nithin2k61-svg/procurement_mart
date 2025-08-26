{{ config(materialized="table") }}

with BOOKINGS_FEED_PUSH as (
select
Level,
SF_Account_Name ,
Salesforce_Number,
sf_Opportunity_Number, 
sf_Opportunity_Name,
Product,
sf_Opportunity_Owner, 
account_type,
vertical,
booking_type,
Probability_Pct,
Close_Date, 
Fiscal_Quarter,
total,
CreatedDate,
sf_sales_market,
Salesforce_Parent,
Business_Unit,
Line_of_Business,
Segment,
notes, 
row_cre_dt,
row_cre_usr_id,
row_mod_dt,
row_mod_usr_id
from 
{{ref('BOOKINGS_FEED')}}
WHERE MONTH(CLOSE_DATE)= MONTH(CURRENT_DATE())-1 
)
SELECT * FROM BOOKINGS_FEED_PUSH