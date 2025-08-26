
{{ config(materialized='incremental', dist='src_uniq_cd', unique_key = 'src_uniq_cd', on_schema_change='sync_all_columns' ) }}

with dim_date as (
select
A.DIM_DATE_ID,
A.DATEDAY,
A.DATEYEAR,
A.DATEHALFID::varchar(20) as DATEHALFID,
A.DATEHALF,
A.DATEQUARTERID::varchar(20) as DATEQUARTERID,
A.DATEQUARTER,
A.DATEMONTHID::varchar(20) as DATEMONTHID,
A.DATEMONTH,
A.DATEWEEKID::varchar(20) as DATEWEEKID,
A.DATEWEEK,
A.DATEDAYOFYEAR,
A.DATEDAYOFMONTH,
A.DATEDAYOFWEEK,
A.DATEDAYEXCLUDEWEEKENDS,
A.DATEMONTHSSRS,
A.BUSINESSDAY,
A.WEEKID::varchar(20) as WEEKID,
A.FINANCEDAYS,
A.src_uniq_cd,
A.del_indc,
A.row_cre_dt,
A.row_cre_usr_id,
A.row_mod_dt,
A.row_mod_usr_id
from {{ ref('intr_dim_date') }} A

{% if is_incremental() %}

left outer join 
{{ this }} B on (A.src_uniq_cd = B.src_uniq_cd)
where B.src_uniq_cd is null


UNION ALL 

select
A.DIM_DATE_ID,
A.DATEDAY,
A.DATEYEAR,
A.DATEHALFID::varchar(20) as DATEHALFID,
A.DATEHALF,
A.DATEQUARTERID::varchar(20) as DATEQUARTERID,
A.DATEQUARTER,
A.DATEMONTHID::varchar(20) as DATEMONTHID,
A.DATEMONTH,
A.DATEWEEKID::varchar(20) as DATEWEEKID,
A.DATEWEEK,
A.DATEDAYOFYEAR,
A.DATEDAYOFMONTH,
A.DATEDAYOFWEEK,
A.DATEDAYEXCLUDEWEEKENDS,
A.DATEMONTHSSRS,
A.BUSINESSDAY,
A.WEEKID::varchar(20) as WEEKID,
A.FINANCEDAYS,
A.src_uniq_cd,
A.del_indc,
B.row_cre_dt,
B.row_cre_usr_id,
A.row_mod_dt,
A.row_mod_usr_id
from {{ ref('intr_dim_date') }} A
left outer join 
{{ this }} B on (A.src_uniq_cd = B.src_uniq_cd)
where B.src_uniq_cd is not null

{% endif %}
)
select * from dim_date 
