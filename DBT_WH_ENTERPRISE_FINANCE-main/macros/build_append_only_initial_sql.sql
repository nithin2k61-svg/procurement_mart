{%- macro build_append_only_initial_sql(target_relation, temp_relation) -%}

{% set query_tag = {} %}
    {%- do query_tag.update(
        PROJECT_NAME=project_name,  
        BU='ENTERPRISE FINANCE',
		APP='dbt', 
        DBT_SNOWFLAKE_QUERY_TAGS_VERSION='2.5.0',
        THREAD_ID=thread_id,
        IS_INCREMENTAL=is_incremental()
    ) -%}
{% set query_tag_json = tojson(query_tag) %}
{% do run_query("alter session set query_tag = '{}'".format(query_tag_json)) %}    
    
    {{ create_table_as(True, temp_relation, sql) }}
    {%- set initial_sql -%}
        SELECT
        B.snap_datetime as snap_datetime,A.*
        FROM
          {{ temp_relation }} A, {{ref('stg_snap_datetime')}} B
    {%- endset -%}
    {{ create_table_as(False, target_relation, initial_sql) }}
{%- endmacro -%}