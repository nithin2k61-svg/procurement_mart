{{ config(materialized='view') }}
with CLIENT_REVENUE as (
SELECT 
    DC.DIM_CLIENT_ID AS CLIENTID,
    DBU.BUSINESSUNITNAME AS BUSINESSUNIT,
    DC.financeparent AS FINANACEPARENT ,
    DC.CLIENTNAME AS CLIENT,
    T.LEVEL_NAME AS LEVEL_NAME ,
    T.TRAN_TYP AS TRAN_TYPE,
    T.REVENUE_GL_ACCOUNT AS REVENUE_GL_ACCOUNT,
    D.DATEday AS DATEDAY,
    EXTRACT(YEAR
FROM
    D.DATEday) AS YEAR_R, 
    D.DATEMONTHID AS YEARMONTH,
    DC.ACCOUNT_PARENT_NAME AS SF_PARENT,
    DC.Account_ID AS SalesForceID,
    P.PRODUCT_TYPE AS PRODUCT_TYPE,
    P.PRODUCT AS PRODUCT,
    P.PRODUCT_TYPE_GROUP AS PRODUCT_TYPE_GROUP ,
    P.PRODUCT AS SUB_PRODUCT,
    CONCAT(DC.ACCOUNT_NAME||' '||DC.ACCOUNT_ID) AS ACCOUNT_NAME_ID,   
    u1."Name" AS CCS_AC_MANAGER,
    u2."Name" AS PPS_AC_MANAGER,
    u3."Name" AS DEF_AC_MANAGER,
    CASE
        WHEN T.TRAN_TYP = 'ACTUALS'
        THEN sum(T.REV_AMOUNT)
        ELSE 0
    END ACTUALS,
    CASE
        WHEN T.TRAN_TYP = 'PLAN'
        THEN sum(T.REV_AMOUNT)
        ELSE 0
    END PLAN_A,
    CASE
        WHEN T.TRAN_TYP = 'FORECAST'
        THEN sum(T.REV_AMOUNT)
        ELSE 0
    END FORECAST
FROM
    {{ ref('fact_fullrev_aggr') }} T
INNER JOIN {{ ref('dim_product_type') }} P ON
    T.DIM_PRODUCT_TYPE_ID = P.DIM_PRODUCT_TYPE_ID
INNER JOIN {{ ref('dim_date') }} D ON
    D.dim_date_id = T.dim_date_id
INNER JOIN {{ ref('dim_client') }} DC ON
    DC.DIM_CLIENT_ID = T.DIM_CLIENT_ID
INNER JOIN {{ ref('dim_source_system') }} DSS ON
    DSS.DIM_SOURCE_SYSTEM_ID = T.DIM_SOURCE_SYSTEM_ID
INNER JOIN {{ ref('dim_business_unit') }} DBU ON
    DBU.DIM_BUSINESS_UNIT_ID = T.DIM_BUSINESS_UNIT_ID
LEFT JOIN 
           {{ source("ads_reporting_sources","dimuser") }} u1    
           on dc.team_am_ccs = u1."UserID"
        left join
             {{ source("ads_reporting_sources","dimuser") }} u2
            on dc.team_am_pps = u2."UserID"
        left join
             {{ source("ads_reporting_sources","dimuser") }} u3
            on dc.team_am_def = u3."UserID"
WHERE
    DSS.SOURCESYSTEMNAME = 'ADAPTIVE'
    AND T.REVENUE_GL_ACCOUNT NOT IN ('41600_Postage_', '41600__')
    AND (
        (T.TRAN_TYP = 'ACTUALS' AND D.DATEday <= DATE_TRUNC('month', CURRENT_DATE()))
        OR (T.TRAN_TYP IN ('PLAN', 'FORECAST') AND SUBSTR(D.DATEday, 1, 4) > 2021)
        )

GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20
    )
,fact_client_revenue  as 
(  
SELECT
    sum(ACTUALS) AS ACTUALS,
    sum(PLAN_A) AS PLAN,
    sum(FORECAST) AS FORECAST,
    SF_PARENT,
    FINANACEPARENT,
    CLIENT,
    CLIENTID,
    BUSINESSUNIT,
    DATEDAY,
    YEAR_R,
    SalesForceID,
    PRODUCT_TYPE,
    LEVEL_NAME ,
    TRAN_TYPE ,
    REVENUE_GL_ACCOUNT,
    PRODUCT_TYPE_GROUP ,
    SUB_PRODUCT,
    ACCOUNT_NAME_ID,   
    CCS_AC_MANAGER,
    PPS_AC_MANAGER,
    DEF_AC_MANAGER
FROM
    CLIENT_REVENUE 
GROUP BY
    SF_PARENT,
    FINANACEPARENT,
    CLIENT,
    CLIENTID,
    BUSINESSUNIT,
    DATEDAY,
    YEAR_R,
    SalesForceID,
    PRODUCT_TYPE,
    LEVEL_NAME ,
    TRAN_TYPE ,
    REVENUE_GL_ACCOUNT,
    PRODUCT_TYPE_GROUP ,
    SUB_PRODUCT,
    ACCOUNT_NAME_ID,   
    CCS_AC_MANAGER,
    PPS_AC_MANAGER,
    DEF_AC_MANAGER
)
select * from fact_client_revenue
