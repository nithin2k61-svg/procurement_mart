{{ config(materialized="table") }}

WITH Preprocessed AS (
    SELECT DISTINCT
        LEVEL_4_CODE,
        ATTRIBUTE_NAME,
        CASE
            WHEN ATTRIBUTE_NAME = 'Corporate Mgt Business Unit' AND ATTRIBUTE_VALUE = 'Enterprise'
            THEN 'Corporate'
            ELSE ATTRIBUTE_VALUE
        END AS ATTRIBUTE_VALUE
    FROM  {{ source("adaptive_comm_sources", "LEVELS") }} 
    WHERE
        ATTRIBUTE_NAME = 'Corporate Mgt Business Unit' AND
        LEVEL_4_CODE IS NOT NULL AND LEVEL_4_CODE <> ''
),
Pivoted AS (
    SELECT *
    FROM Preprocessed
    PIVOT (
        MAX(ATTRIBUTE_VALUE)
        FOR ATTRIBUTE_NAME IN ('Corporate Mgt Business Unit')
    ) AS PivotTable (LEVEL_4_CODE, CORPORATE_MGT_BUSINESS_UNIT)
),
stg_headcount_aggr AS (
    SELECT 
        'unknown' AS CLIENT_ID,
        'unknown' AS PRODUCT_TYPE_ID,
        6 AS SRC_SYS_ID,
        CASE 
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Price%' THEN '1'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Payments%' THEN '2'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Insights & Empowerment%' THEN '4'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Corporate%' THEN '5'
            ELSE '-1'
        END AS BUSINESS_UNIT_ID,
        'unknown' AS PROVIDER_ID,
        a.yearmonth AS DATEKEY,
        a.ACCOUNT_NAME,
        a.LEVEL_NAME,
        'ACTUALS' AS TRAN_TYP,
        COALESCE(SUM(rollup),0) AS TOTAL_COUNT,
        CONCAT(SRC_SYS_ID, '_', CLIENT_ID) AS srcuniqcd_dim_client,
        CONCAT(SRC_SYS_ID, '_', PROVIDER_ID) AS srcuniqcd_dim_provider,
        CONCAT('7', '_', PRODUCT_TYPE_ID) AS srcuniqcd_dim_product_type,
        CONCAT('7', '_', SRC_SYS_ID) AS srcuniqcd_dim_source_system,
    CONCAT('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    FROM  {{source('adaptive_comm_sources','ACTUALS_HEADCOUNT')}} a
    left outer join Pivoted p ON a.LEVEL_NAME = p.LEVEL_4_CODE
  GROUP BY 
    p.CORPORATE_MGT_BUSINESS_UNIT,
	CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME

    UNION ALL

    SELECT 
        'unknown' AS CLIENT_ID,
        'unknown' AS PRODUCT_TYPE_ID,
        6 AS SRC_SYS_ID,
        CASE 
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Price%' THEN '1'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Payments%' THEN '2'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Insights & Empowerment%' THEN '4'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Corporate%' THEN '5'
            ELSE '-1'
        END AS BUSINESS_UNIT_ID,
        'unknown' AS PROVIDER_ID,
        a.yearmonth AS DATEKEY,
        a.ACCOUNT_NAME,
        a.LEVEL_NAME,
        'PLAN' AS TRAN_TYP,
    coalesce(sum(rollup),0) as TOTAL_COUNT,
    CONCAT(SRC_SYS_ID, '_', CLIENT_ID) as srcuniqcd_dim_client,
    CONCAT(SRC_SYS_ID, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    CONCAT('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    CONCAT('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    CONCAT('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    FROM  {{source('adaptive_comm_sources','PLAN_HEADCOUNT')}} a
    left outer join Pivoted p ON a.LEVEL_NAME = p.LEVEL_4_CODE
  GROUP BY 
    p.CORPORATE_MGT_BUSINESS_UNIT,
	CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME

    UNION ALL

    SELECT 
        'unknown' AS CLIENT_ID,
        'unknown' AS PRODUCT_TYPE_ID,
        6 AS SRC_SYS_ID,
        CASE 
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Price%' THEN '1'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Payments%' THEN '2'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Insights & Empowerment%' THEN '4'
            WHEN p.CORPORATE_MGT_BUSINESS_UNIT LIKE '%Corporate%' THEN '5'
            ELSE '-1'
        END AS BUSINESS_UNIT_ID,
        'unknown' AS PROVIDER_ID,
        a.yearmonth AS DATEKEY,
        a.ACCOUNT_NAME,
        a.LEVEL_NAME,
        'FORECAST' AS TRAN_TYP,
    coalesce(sum(rollup),0) as TOTAL_COUNT,
    CONCAT(SRC_SYS_ID, '_', CLIENT_ID) as srcuniqcd_dim_client,
    CONCAT(SRC_SYS_ID, '_', PROVIDER_ID) as srcuniqcd_dim_provider,
    CONCAT('7', '_', PRODUCT_TYPE_ID) as srcuniqcd_dim_product_type,
    CONCAT('7', '_', SRC_SYS_ID) as srcuniqcd_dim_source_system,
    CONCAT('7', '_', BUSINESS_UNIT_ID) as srcuniqcd_dim_business_unit
    FROM  {{source('adaptive_comm_sources','FORECAST_HEADCOUNT')}} a
    left outer join Pivoted p ON a.LEVEL_NAME = p.LEVEL_4_CODE
    GROUP BY 
    p.CORPORATE_MGT_BUSINESS_UNIT,
	CLIENT_ID,
    PRODUCT_TYPE_ID,
    SRC_SYS_ID,
    BUSINESS_UNIT_ID,
    PROVIDER_ID,
    DATEKEY,
    TRAN_TYP,
    ACCOUNT_NAME,
    LEVEL_NAME
),
stg_headcount AS (
    SELECT
        CLIENT_ID,
        PRODUCT_TYPE_ID,
        SRC_SYS_ID,
        BUSINESS_UNIT_ID,
        PROVIDER_ID,
        DATEKEY,
        ACCOUNT_NAME,
        LEVEL_NAME,
        TRAN_TYP,
        TOTAL_COUNT,
        srcuniqcd_dim_client,
        srcuniqcd_dim_provider,
        srcuniqcd_dim_product_type,
        srcuniqcd_dim_source_system,
        srcuniqcd_dim_business_unit 
    from stg_headcount_aggr a
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on try_to_date(a.DATEKEY, 'MONYYYY') = monthdate.dateday
    ORDER BY PRODUCT_TYPE_ID, BUSINESS_UNIT_ID, DATEKEY            
)
SELECT * FROM stg_headcount