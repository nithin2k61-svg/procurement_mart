{{ config(materialized='view') }}
WITH cogs_pps as (
    
    select dat."Date Day" DATEDAY,
    cogs.dim_date_id,
    client.financeparent as PAYERID,
    product.product_type as product_type,
    null as CHARGED_AMOUNT,
    null as REVENUE_AMOUNT,
    SUM(crev_amount)*-1 as COGS_AMOUNT,
    case when cogs.account_name in ('50200 - Administrative Fees',
                                    '50200 - Administrative Fees - Unsettled',
                                    '50200 - Settled and Administrative Fees',
                                    '50200 - Unsettled and Administrative Fees - Unsettled') then 'Admin Allowance' 
 
     when cogs.account_name in ('50600 - Broker Fees',
                                '50600 - Referral Broker Fees',
                                '50600 - Referral Broker Fees - Unsettled',
                                '50600 - Settled and Referral Broker Fees',
                                '50600 - Unsettled and Referral Broker Fees - Unsettled') then 'Broker Fees'

     when cogs.account_name in ('50610 - Adjudication Interface Fees',
                                '50610 - Adjudication Interface Fees - Unsettled',
                                '50610 - Settled and Adjudication Interface Fees',
                                '50610 - Unsettled and Adjudication Interface Fees - Unsettled')   then 'Adjudication Fees'


    when cogs.account_name in ('50670 - Card Settlement Fees') then 'Card Settlement Fees'

    when cogs.account_name in ('50670 - Charges Other',
                               '50670 - Charges Other - Unsettled',
                               '50670 - Settled and Charges Other',
                               '50670 - Unsettled and Charges Other - Unsettled',
                               '50670 - COGS Other',
                               '50670 - Other COS') then 'Other COGS'

    when cogs.account_name in ('50670 - COGS Bank Charges') then 'Bank Charges'

when cogs.account_name in ('50670 - Fax Service Fees',
'50670 - Fax Service Fees - Unsettled',
'50670 - Settled and Fax Service Fees',
'50670 - Unsettled and Fax Service Fees - Unsettled'
)
 then  'Fax Service Fees'

when cogs.account_name in ('50670 - Mastercard Brand',
'50670 - MC Acquiring Fees',
'50670 - PPS Mastercard Subsidy',
'50670 - Settled and PPS Mastercard Subsidy'
) then 'Mastercard'

when cogs.account_name in ('50670 - Print Vendor Fees') then 'Print Vendor Fees'

when cogs.account_name in ('50670 - Royalty Agreements',
'50670 - Settled and Royalty Agreements',
'50670 - Royalty Agreements - Unsettled',
'50670 - Unsettled and Royalty Agreements - Unsettled') then 'Royalty Fees'

ELSE 'Not In Cogs'


END  AS ACCOUNT_DISPLAY_NAME
    
    
   from {{ ref('fact_crev_aggr') }}  cogs
    
      inner join {{ ref('dim_client') }} client
      on client.dim_client_id=cogs.dim_client_id
    
      inner join {{ ref('dimdate') }} dat
      on dat.dim_date_id=cogs.dim_date_id
          
      inner join {{ ref('dim_product_type') }}  product
      
      on product.dim_product_type_id=cogs.dim_product_type_id
    
       where cogs.tran_typ='ACTUALS' and cogs.level_name='Zelis Consolidated (Rollup)' 
       
      
      
      
    group by
     dat."Date Day",
    cogs.dim_date_id,
    client.financeparent,
    product.PRODUCT_TYPE,
    ACCOUNT_DISPLAY_NAME
    
    ) ,
PAYER_PPS AS (
SELECT 
    dat."Date Day" DATEDAY,
    pps.dim_date_id,
    client.financeparent as PAYERID,
    product.product_type as product_type, 
    CASE
            WHEN sum(
                CASE
                    WHEN product_type = 'SAAS' then 0
                    ELSE ROUND(pps.VOLUME_AMOUNT, 2)
                END
            ) = 0 THEN NULL
            ELSE sum(
                CASE
                    WHEN product_type = 'SAAS' then 0
                    WHEN product_type IN ('Communication', 'Enrollment') and pps.VOLUME_AMOUNT <3  then 0
                    ELSE ROUND(pps.VOLUME_AMOUNT, 2)
                END
            )
        END CHARGED_AMOUNT, 
    CASE WHEN sum(pps.NET_REVENUE_AMOUNT) = 0 THEN NULL ELSE sum(pps.NET_REVENUE_AMOUNT) END REVENUE_AMOUNT

FROM  {{ ref('fact_revenue_aggr') }}  pps

INNER JOIN  {{ ref('dimdate') }} dat
    on dat.dim_date_id = pps.dim_date_id
	
INNER JOIN {{ ref('dim_business_unit') }} business_unit
    on business_unit.dim_business_unit_id = pps.dim_business_unit_id
	
inner join {{ ref('dim_product_type') }} product
    on product.dim_product_type_id = pps.dim_product_type_id
	
inner join {{ ref('dim_client') }} client
    on client.dim_client_id = pps.dim_client_id


WHERE
    dat."Date Day" < DATE_TRUNC('MONTH',GETDATE())
and business_unit.BUSINESSUNITNAME in ('Payments', 'Communications')
and product.product_type not in ('Others')




       
GROUP BY
    dat."Date Day",
    pps.dim_date_id,
    client.financeparent,
    product.PRODUCT_TYPE
),

COGS_AND_PAYER_PPS as(

select 
    pps.DATEDAY,
    pps.dim_date_id,
    pps.PAYERID,
    pps.product_type, 
    cogs.ACCOUNT_DISPLAY_NAME,
    sum(pps.charged_amount) as charged_amount,
    sum(pps.revenue_amount) as revenue_amount,
    avg(cogs.COGS_AMOUNT) as cogs_amount,
    sum( pps.revenue_amount) +coalesce(cogs_sum.cogs_sum, 0) AS GROSS_PROFIT

    
from payer_pps as pps 

left join cogs_pps as cogs 
on cogs.DATEDAY = pps.DATEDAY 
and cogs.payerid = pps.payerid
and cogs.PRODUCT_TYPE = pps.PRODUCT_TYPE



left join ( 
select 
dateday, payerid, product_type, 
sum(cogs_amount) as cogs_sum from cogs_pps 
where cogs_pps.account_display_name in ('Admin Allowance','Broker Fees','Adjudication Fees','Card Settlement Fees','Other COGS','Bank Charges','Fax Service Fees','Mastercard','Royalty Fees' )
group by dateday, payerid, product_type) cogs_sum 
on cogs_sum.DATEDAY = pps.DATEDAY 
and cogs_sum.payerid = pps.payerid
and cogs_sum.PRODUCT_TYPE = pps.PRODUCT_TYPE


where
cogs.ACCOUNT_DISPLAY_NAME in ('Admin Allowance','Broker Fees','Adjudication Fees','Card Settlement Fees','Other COGS','Bank Charges','Fax Service Fees','Mastercard','Royalty Fees' )

group by 
    pps.DATEDAY,
    pps.dim_date_id,
    pps.PAYERID,
    pps.product_type, 
   cogs.ACCOUNT_DISPLAY_NAME,cogs_sum.cogs_sum

),
    

ALLFACTCOMBOS AS (

SELECT d.DATEDAY, d.dim_date_id, p.PAYERID, p.PRODUCT_TYPE, p.ACCOUNT_DISPLAY_NAME FROM (SELECT DISTINCT DATEDAY, dim_date_id FROM PAYER_PPS) d
JOIN LATERAL (SELECT DISTINCT PAYERID, product_type, ACCOUNT_DISPLAY_NAME FROM COGS_AND_PAYER_PPS) p ),






REVENUE AS 

(
SELECT
DATEDAY,
dim_date_id, 
PAYERID, 
product_type,
ACCOUNT_DISPLAY_NAME,
DATEADD(year,1,DATEDAY) PYDATEDAY, 
DATEADD(year,2,DATEDAY) TWOPYDATEDAY,
DATEADD(month,1,DATEDAY) PMDATEDAY, 
DATEADD(month,2,DATEDAY) TWOPMDATEDAY, 
DATEADD(quarter,1,DATEDAY) PQDATEDAY, 
DATEADD(quarter,2,DATEDAY) TWOPQDATEDAY, 
REVENUE_AMOUNT REVENUE_AMOUNT,
CHARGED_AMOUNT CHARGED_AMOUNT,
COGS_AMOUNT COGS_AMOUNT,
GROSS_PROFIT GROSS_PROFIT,
IFNULL(REVENUE_AMOUNT/NULLIF(CHARGED_AMOUNT,0),0) PRICE,
IFNULL(COGS_AMOUNT/NULLIF(CHARGED_AMOUNT,0),0) COGS_PRICE,

FROM COGS_AND_PAYER_PPS
),


    

Cohorts_COGS AS 

(

	SELECT CY.dim_date_id, CY.PAYERID, CY.PRODUCT_TYPE, CY.PYDATEDAY, CY.PMDATEDAY, CY.PQDATEDAY, CY.DATEDAY,CY.ACCOUNT_DISPLAY_NAME,
    
   
 

    	CASE
		WHEN CY.PRODUCT_TYPE IN ('Communication', 'Enrollment') THEN

CASE
			WHEN IFNULL(CY.PRICE * PY.PRICE,
			0) <> 0
			AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
			0),
			0) <> 0
			AND ROUND(IFNULL(PY.REVENUE_AMOUNT,
			0),
			0) <> 0
			AND CY.CHARGED_AMOUNT > 2
			AND PY.CHARGED_AMOUNT > 2 THEN IFNULL((CY.PRICE - PY.PRICE) * CY.CHARGED_AMOUNT,
			0)
			ELSE 0
		END
		ELSE

CASE
			WHEN IFNULL(CY.PRICE * PY.PRICE,
			0) <> 0
			AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
			0),
			0) <> 0
			AND ROUND(IFNULL(PY.REVENUE_AMOUNT,
			0),
			0) <> 0 THEN IFNULL((CY.PRICE - PY.PRICE) * CY.CHARGED_AMOUNT,
			0)
			ELSE 0
		END
	END DELTAPRICEYEAR,
	
	
		CASE
		WHEN CY.PRODUCT_TYPE IN ('ACH+-Settled', 'VCC-UnSettled', 'VCC-Settled', 'EPC Payer-Sponsored')  --OR  CY.ACCOUNT_DISPLAY_NAME NOT IN ('Royalty Fees') 
        THEN

CASE
			WHEN IFNULL(CY.COGS_PRICE * PY.COGS_PRICE,
			0) <> 0
			AND ROUND(IFNULL(CY.COGS_AMOUNT,
			0),
			0) <> 0
			AND ROUND(IFNULL(PY.COGS_AMOUNT,
			0),
			0) <> 0

            AND  CY.ACCOUNT_DISPLAY_NAME <>'Royalty Fees'
			
			 THEN IFNULL((CY.COGS_PRICE - PY.COGS_PRICE) * CY.CHARGED_AMOUNT,
			0)
			ELSE 0
		END
		ELSE
CASE
			WHEN IFNULL(CY.COGS_PRICE * PY.COGS_PRICE,
			0) <> 0
			AND ROUND(IFNULL(CY.COGS_AMOUNT,
			0),
			0) <> 0
			AND ROUND(IFNULL(PY.COGS_AMOUNT,
			0),
			0) <> 0 THEN IFNULL((CY.COGS_PRICE - PY.COGS_PRICE) * CY.CHARGED_AMOUNT,
			0)
			ELSE 0
		END
	END DELTAPRICEYEAR_COGS,

    
CASE WHEN CY.PRODUCT_TYPE IN ('Communication', 'Enrollment') THEN
CASE WHEN IFNULL(CY.PRICE * PQ.PRICE,0) <> 0 AND ROUND(IFNULL(CY.REVENUE_AMOUNT,0),0) <> 0 AND ROUND(IFNULL(PQ.REVENUE_AMOUNT,0),0) <> 0 AND CY.CHARGED_AMOUNT > 2 AND PQ.CHARGED_AMOUNT > 2 THEN IFNULL((CY.PRICE - PQ.PRICE) * CY.CHARGED_AMOUNT,0) ELSE 0 END
ELSE
CASE WHEN IFNULL(CY.PRICE * PQ.PRICE,0) <> 0 AND ROUND(IFNULL(CY.REVENUE_AMOUNT,0),0) <> 0 AND ROUND(IFNULL(PQ.REVENUE_AMOUNT,0),0) <> 0 THEN  IFNULL((CY.PRICE - PQ.PRICE) * CY.CHARGED_AMOUNT,0) ELSE 0 END END DELTAPRICEQUARTER,




CASE
	WHEN CY.PRODUCT_TYPE IN ('ACH+-Settled', 'VCC-UnSettled', 'VCC-Settled', 'EPC Payer-Sponsored') 
    THEN
CASE WHEN IFNULL(CY.COGS_PRICE * PQ.COGS_PRICE,0) <> 0 AND ROUND(IFNULL(CY.COGS_AMOUNT,0),0) <> 0 AND ROUND(IFNULL(PQ.COGS_AMOUNT,0),0) <> 0 AND  CY.ACCOUNT_DISPLAY_NAME <>'Royalty Fees'

THEN IFNULL((CY.COGS_PRICE - PQ.COGS_PRICE) * CY.CHARGED_AMOUNT,0) ELSE 0 END

ELSE

CASE WHEN IFNULL(CY.COGS_PRICE * PQ.COGS_PRICE,0) <> 0 AND ROUND(IFNULL(CY.COGS_AMOUNT,0),0) <> 0 AND ROUND(IFNULL(PQ.COGS_AMOUNT,0),0) <> 0 THEN  IFNULL((CY.COGS_PRICE - PQ.COGS_PRICE) * CY.CHARGED_AMOUNT,0) ELSE 0 END END DELTAPRICEQUARTER_COGS,

	CASE
		WHEN CY.PRODUCT_TYPE IN ('ACH+-Settled', 'VCC-UnSettled', 'VCC-Settled', 'EPC Payer-Sponsored')  
        THEN

CASE
			WHEN IFNULL(CY.COGS_PRICE * PM.COGS_PRICE,
			0) <> 0
			AND ROUND(IFNULL(CY.COGS_AMOUNT,
			0),
			0) <> 0
			AND ROUND(IFNULL(PM.COGS_AMOUNT,
			0),
			0) <> 0

            AND  CY.ACCOUNT_DISPLAY_NAME <>'Royalty Fees'
			
			THEN IFNULL((CY.COGS_PRICE - PM.COGS_PRICE) * CY.CHARGED_AMOUNT,
			0)
			ELSE 0
		END
		ELSE
CASE
			WHEN IFNULL(CY.COGS_PRICE * PY.COGS_PRICE,
			0) <> 0
			AND ROUND(IFNULL(CY.COGS_AMOUNT,
			0),
			0) <> 0
			AND ROUND(IFNULL(PM.COGS_AMOUNT,
			0),
			0) <> 0 THEN IFNULL((CY.COGS_PRICE - PM.COGS_PRICE) * CY.CHARGED_AMOUNT,
			0)
			ELSE 0
		END
	END DELTAPRICEMONTH_COGS,


   
CASE
	WHEN CY.PRODUCT_TYPE IN ('Communication', 'Enrollment') THEN
CASE
		WHEN IFNULL(CY.PRICE * PQ.PRICE,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PQ.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND CY.CHARGED_AMOUNT > 2
		AND PM.CHARGED_AMOUNT > 2 THEN IFNULL((CY.PRICE - PM.PRICE) * CY.CHARGED_AMOUNT,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.PRICE * PQ.PRICE,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PQ.REVENUE_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.PRICE - PM.PRICE) * CY.CHARGED_AMOUNT,
		0)
		ELSE 0
	END
END DELTAPRICEMONTH,



    

    CASE
	WHEN CY.PRODUCT_TYPE IN ('Communication', 'Enrollment') THEN
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PY.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND CY.CHARGED_AMOUNT > 2
		AND PY.CHARGED_AMOUNT > 2 THEN IFNULL((CY.CHARGED_AMOUNT - PY.CHARGED_AMOUNT) * PY.Price,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PY.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PY.REVENUE_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.CHARGED_AMOUNT - PY.CHARGED_AMOUNT) * PY.Price,
		0)
		ELSE 0
	END
END DELTAVOLUMEYEAR,

CASE
		WHEN CY.PRODUCT_TYPE IN ('ACH+-Settled', 'VCC-UnSettled', 'VCC-Settled', 'EPC Payer-Sponsored') THEN

CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PY.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.COGS_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PY.COGS_AMOUNT,
		0),
		0) <> 0
		
		THEN IFNULL((CY.CHARGED_AMOUNT - PY.CHARGED_AMOUNT) * PY.COGS_PRICE,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PY.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.COGS_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PY.COGS_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.CHARGED_AMOUNT - PY.CHARGED_AMOUNT) * PY.COGS_PRICE,
		0)
		ELSE 0
	END
END DELTAVOLUMEYEAR_COGS,

CASE
	WHEN CY.PRODUCT_TYPE IN ('Communication', 'Enrollment') THEN
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PQ.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PQ.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND CY.CHARGED_AMOUNT > 2
		AND PQ.CHARGED_AMOUNT > 2 THEN IFNULL((CY.CHARGED_AMOUNT - PQ.CHARGED_AMOUNT) * PQ.PRICE,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PQ.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PQ.REVENUE_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.CHARGED_AMOUNT - PQ.CHARGED_AMOUNT) * PQ.PRICE,
		0)
		ELSE 0
	END
END DELTAVOLUMEQUARTER,


CASE
		WHEN CY.PRODUCT_TYPE IN ('ACH+-Settled', 'VCC-UnSettled', 'VCC-Settled', 'EPC Payer-Sponsored') THEN

CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PY.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.COGS_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PQ.COGS_AMOUNT,
		0),
		0) <> 0
		
		 THEN IFNULL((CY.CHARGED_AMOUNT - PQ.CHARGED_AMOUNT) * PQ.COGS_PRICE,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PQ.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.COGS_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PQ.COGS_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.CHARGED_AMOUNT - PQ.CHARGED_AMOUNT) * PQ.COGS_PRICE,
		0)
		ELSE 0
	END
END DELTAVOLUMEQUARTER_COGS,

CASE
	WHEN CY.PRODUCT_TYPE IN ('Communication', 'Enrollment') THEN
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PM.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PM.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND CY.CHARGED_AMOUNT > 2
		AND PM.CHARGED_AMOUNT > 2 THEN IFNULL((CY.CHARGED_AMOUNT - PM.CHARGED_AMOUNT) * PM.PRICE,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PM.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.REVENUE_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PM.REVENUE_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.CHARGED_AMOUNT - PM.CHARGED_AMOUNT) * PM.PRICE,
		0)
		ELSE 0
	END
END DELTAVOLUMEMONTH,

CASE
		WHEN CY.PRODUCT_TYPE IN ('ACH+-Settled', 'VCC-UnSettled', 'VCC-Settled', 'EPC Payer-Sponsored') THEN
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PM.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.COGS_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PM.COGS_AMOUNT,
		0),
		0) <> 0
		
		THEN IFNULL((CY.CHARGED_AMOUNT - PM.CHARGED_AMOUNT) * PM.COGS_PRICE,
		0)
		ELSE 0
	END
	ELSE
CASE
		WHEN IFNULL(CY.CHARGED_AMOUNT * PM.CHARGED_AMOUNT,
		0) <> 0
		AND ROUND(IFNULL(CY.COGS_AMOUNT,
		0),
		0) <> 0
		AND ROUND(IFNULL(PM.COGS_AMOUNT,
		0),
		0) <> 0 THEN IFNULL((CY.CHARGED_AMOUNT - PM.CHARGED_AMOUNT) * PM.COGS_PRICE,
		0)
		ELSE 0
	END
END DELTAVOLUMEMONTH_COGS,


-- ---COGSCONDITION---gross variance---
CASE WHEN ROUND(IFNULL(CY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(PY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(TwoPY.GROSS_PROFIT,0),0) <> 0 THEN 1 ELSE 0 END COGS_YEARBASEFLAG,
CASE WHEN ROUND(IFNULL(CY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(PY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(TwoPY.GROSS_PROFIT,0),0) = 0 THEN 1 ELSE 0 END COGS_YEARRAMPINGFLAG,
CASE WHEN ROUND(IFNULL(CY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(PM.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(TwoPM.GROSS_PROFIT,0),0) <> 0 THEN 1 ELSE 0 END COGS_MONTHBASEFLAG,
CASE WHEN ROUND(IFNULL(CY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(PM.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(TwoPM.GROSS_PROFIT,0),0) = 0 THEN 1 ELSE 0 END COGS_MONTHRAMPINGFLAG,
CASE WHEN ROUND(IFNULL(CY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(PQ.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(TwoPQ.GROSS_PROFIT,0),0) <> 0 THEN 1 ELSE 0 END COGS_QUARTERBASEFLAG,
CASE WHEN ROUND(IFNULL(CY.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(PQ.GROSS_PROFIT,0),0) <> 0 AND ROUND(IFNULL(TwoPQ.GROSS_PROFIT,0),0) = 0 THEN 1 ELSE 0 END COGS_QUARTERRAMPINGFLAG,


	


CASE WHEN ROUND(IFNULL(CY.COGS_AMOUNT,0),0) <> 0 OR ROUND(IFNULL(PY.COGS_AMOUNT,0),0) <> 0 OR ROUND(IFNULL(PM.COGS_AMOUNT,0),0) <> 0 OR ROUND(IFNULL(PQ.COGS_AMOUNT,0),0) <> 0 then 1 else 0 END ROWFILTERFLAG


	
	FROM
	REVENUE CY
    
LEFT JOIN REVENUE PY ON

	CY.DATEDAY = PY.PYDATEDAY
	AND CY.PAYERID = PY.PAYERID
	AND CY.PRODUCT_TYPE = PY.PRODUCT_TYPE
    AND CY.ACCOUNT_DISPLAY_NAME=PY.ACCOUNT_DISPLAY_NAME
    
LEFT JOIN REVENUE TWOPY ON
	CY.DATEDAY = TWOPY.TWOPYDATEDAY
	AND CY.PAYERID = TWOPY.PAYERID
	AND CY.PRODUCT_TYPE = TWOPY.PRODUCT_TYPE
    AND CY.ACCOUNT_DISPLAY_NAME=TWOPY.ACCOUNT_DISPLAY_NAME
    
LEFT JOIN REVENUE PM ON
	CY.DATEDAY = PM.PMDATEDAY
	AND CY.PAYERID = PM.PAYERID
	AND CY.PRODUCT_TYPE = PM.PRODUCT_TYPE
    AND CY.ACCOUNT_DISPLAY_NAME=PM.ACCOUNT_DISPLAY_NAME
    
LEFT JOIN REVENUE TWOPM ON
	CY.DATEDAY = TWOPM.TWOPMDATEDAY
	AND CY.PAYERID = TWOPM.PAYERID
	AND CY.PRODUCT_TYPE = TWOPM.PRODUCT_TYPE
    AND CY.ACCOUNT_DISPLAY_NAME=TWOPM.ACCOUNT_DISPLAY_NAME
    
LEFT JOIN REVENUE PQ ON
	CY.DATEDAY = PQ.PQDATEDAY
	AND CY.PAYERID = PQ.PAYERID
	AND CY.PRODUCT_TYPE = PQ.PRODUCT_TYPE
    AND CY.ACCOUNT_DISPLAY_NAME=PQ.ACCOUNT_DISPLAY_NAME
    
LEFT JOIN REVENUE TWOPQ ON
	CY.DATEDAY = TWOPQ.TWOPQDATEDAY
	AND CY.PAYERID = TWOPQ.PAYERID
	AND CY.PRODUCT_TYPE = TWOPQ.PRODUCT_TYPE
    AND CY.ACCOUNT_DISPLAY_NAME=TWOPQ.ACCOUNT_DISPLAY_NAME
),

cohort_cogs_with_gross as (

select 
 cc.*, 
 cc.deltapricemonth + sum_cohorts.gross_pricemonth_cogs_sum  as price_GROSS_profitmonth,
  cc.deltapricequarter + sum_cohorts.gross_pricequarter_cogs_sum  as price_GROSS_profitquarter,
   cc.deltapriceyear + sum_cohorts.gross_priceyear_cogs_sum  as price_GROSS_profityear,


    cc.deltavolumemonth + sum_cohorts.gross_volumemonth_cogs_sum  as vol_GROSS_profitmonth,
  cc.deltavolumequarter + sum_cohorts.gross_volumequarter_cogs_sum  as vol_GROSS_profitquarter,
   cc.deltavolumeyear + sum_cohorts.gross_volumeyear_cogs_sum  as vol_GROSS_profityear
   
 
from cohorts_cogs as cc 

left join (
select 
    DATEDAY,
    payerid,
    product_type,
    sum(deltapricemonth_cogs) as gross_pricemonth_cogs_sum,
    sum(deltapricequarter_cogs) as gross_pricequarter_cogs_sum,
    sum(deltapriceyear_cogs) as gross_priceyear_cogs_sum,

    sum(DELTAVOLUMEmonth_cogs) as gross_volumemonth_cogs_sum,
    sum(DELTAVOLUMEquarter_cogs) as gross_volumequarter_cogs_sum,
    sum(DELTAVOLUMEYEAR_cogs) as gross_volumeyear_cogs_sum

    

    from cohorts_cogs 
    group by DATEDAY,
    payerid,
    product_type
) as sum_cohorts

on (
cc.DATEDAY = sum_cohorts.DATEDAY and 
cc.payerid = sum_cohorts.payerid and 
cc.product_type = sum_cohorts.product_type
)
),


factpvm_payer_cogs as 
(
SELECT 
t1.DATEDAY, 
t1.dim_date_id,
t1.PAYERID,
t1.product_type,
t1.ACCOUNT_DISPLAY_NAME,
COCY.DELTAPRICEYEAR,
COCY.DELTAPRICEQUARTER,
COCY.DELTAPRICEMONTH,
COCY.DELTAVOLUMEYEAR,
COCY.DELTAVOLUMEQUARTER,
COCY.DELTAVOLUMEMONTH,
---COGS-----
COCY.DELTAPRICEYEAR_COGS,
COCY.DELTAPRICEQUARTER_COGS,
COCY.DELTAPRICEMONTH_COGS,
COCY.DELTAVOLUMEYEAR_COGS,
COCY.DELTAVOLUMEQUARTER_COGS,
COCY.DELTAVOLUMEMONTH_COGS,

COCY.price_GROSS_profitmonth,
COCY.price_GROSS_profitquarter,
COCY.price_GROSS_profityear,
COCY.vol_GROSS_profitmonth,
COCY.vol_GROSS_profitquarter,
COCY.vol_GROSS_profityear,



IFNULL(COCY.COGS_YEARBASEFLAG,0) AS COGS_YEARBASEFLAG, 
IFNULL(COCY.COGS_YEARRAMPINGFLAG,0) AS COGS_YEARRAMPINGFLAG, 
IFNULL(COCY.COGS_QUARTERBASEFLAG,0) AS COGS_QUARTERBASEFLAG, 
IFNULL(COCY.COGS_QUARTERRAMPINGFLAG,0) AS COGS_QUARTERRAMPINGFLAG, 
IFNULL(COCY.COGS_MONTHBASEFLAG,0) AS COGS_MONTHBASEFLAG, 
IFNULL(COCY.COGS_MONTHRAMPINGFLAG,0) AS COGS_MONTHRAMPINGFLAG,

IFNULL(COHPY.COGS_YEARBASEFLAG,0) COGS_PYYEARBASEFLAG, 
IFNULL(COHPY.COGS_YEARRAMPINGFLAG,0) COGS_PYYEARRAMPINGFLAG,
IFNULL(COHPQ.COGS_QUARTERBASEFLAG,0) COGS_PQQUARTERBASEFLAG,
IFNULL(COHPQ.COGS_QUARTERRAMPINGFLAG,0) COGS_PQQUARTERRAMPINGFLAG,
IFNULL(COHPM.COGS_MONTHBASEFLAG,0) COGS_PMMONTHBASEFLAG, 
IFNULL(COHPM.COGS_MONTHRAMPINGFLAG,0) COGS_PMMONTHRAMPINGFLAG,


avg(t2.REVENUE_AMOUNT) as REVENUE_AMOUNT, 
avg(t2.CHARGED_AMOUNT) as CHARGED_AMOUNT,
avg(t2.COGS_AMOUNT) as COGS_AMOUNT,
AVG(GROSS_PROFIT) AS GROSS_PROFIT


FROM ALLFACTCOMBOS t1

LEFT JOIN REVENUE t2 on t1.dim_date_id = t2.dim_date_id and t1.PAYERID = t2.PAYERID  and t1.product_type = t2.product_type and  t1.ACCOUNT_DISPLAY_NAME=t2.ACCOUNT_DISPLAY_NAME


LEFT JOIN cohort_cogs_with_gross COCY on t1.dim_date_id = COCY.dim_date_id and t1.PAYERID = COCY.PAYERID and  t1.product_type = COCY.product_type and t1.ACCOUNT_DISPLAY_NAME=COCY.ACCOUNT_DISPLAY_NAME



LEFT JOIN cohort_cogs_with_gross COHPY on t1.DATEDAY = DATEADD(year,-1,COHPY.DATEDAY) and t1.PAYERID = COHPY.PAYERID and  t1.product_type = COHPY.product_type
and t1.ACCOUNT_DISPLAY_NAME=COHPY.ACCOUNT_DISPLAY_NAME

LEFT JOIN cohort_cogs_with_gross COHPQ on t1.DATEDAY = DATEADD(quarter,-1,COHPQ.DATEDAY) and t1.PAYERID = COHPQ.PAYERID and  t1.product_type = COHPQ.product_type
and T1.ACCOUNT_DISPLAY_NAME=COHPQ.ACCOUNT_DISPLAY_NAME

LEFT JOIN cohort_cogs_with_gross COHPM on t1.DATEDAY = DATEADD(month,-1,COHPM.DATEDAY) and t1.PAYERID = COHPM.PAYERID and  t1.product_type = COHPM.product_type
and t1.ACCOUNT_DISPLAY_NAME=COHPM.ACCOUNT_DISPLAY_NAME 

WHERE COCY.ROWFILTERFLAG = 1



group by 
t1.DATEDAY, 
t1.dim_date_id,
t1.PAYERID, 
t1.product_type,
t1.ACCOUNT_DISPLAY_NAME,
COCY.DELTAPRICEYEAR,
COCY.DELTAPRICEQUARTER,
COCY.DELTAPRICEMONTH,
COCY.DELTAVOLUMEYEAR,
COCY.DELTAVOLUMEQUARTER,
COCY.DELTAVOLUMEMONTH,
---cogs-----

COCY.DELTAPRICEYEAR_COGS,
COCY.DELTAPRICEQUARTER_COGS,
COCY.DELTAPRICEMONTH_COGS,
COCY.DELTAVOLUMEYEAR_COGS,
COCY.DELTAVOLUMEQUARTER_COGS,
COCY.DELTAVOLUMEMONTH_COGS,



COCY.price_GROSS_profitmonth,
COCY.price_GROSS_profitquarter,
COCY.price_GROSS_profityear,
COCY.vol_GROSS_profitmonth,
COCY.vol_GROSS_profitquarter,
COCY.vol_GROSS_profityear,

-------------------------
IFNULL(COCY.COGS_YEARBASEFLAG,0), 
IFNULL(COCY.COGS_YEARRAMPINGFLAG,0) ,
IFNULL(COCY.COGS_QUARTERBASEFLAG,0), 
IFNULL(COCY.COGS_QUARTERRAMPINGFLAG,0), 
IFNULL(COCY.COGS_MONTHBASEFLAG,0), 
IFNULL(COCY.COGS_MONTHRAMPINGFLAG,0), 
IFNULL(COHPY.COGS_YEARBASEFLAG,0) , 
IFNULL(COHPY.COGS_YEARRAMPINGFLAG,0) ,
IFNULL(COHPQ.COGS_QUARTERBASEFLAG,0) ,
IFNULL(COHPQ.COGS_QUARTERRAMPINGFLAG,0) ,
IFNULL(COHPM.COGS_MONTHBASEFLAG,0) , 
IFNULL(COHPM.COGS_MONTHRAMPINGFLAG,0)

)


select * from factpvm_payer_cogs


    
