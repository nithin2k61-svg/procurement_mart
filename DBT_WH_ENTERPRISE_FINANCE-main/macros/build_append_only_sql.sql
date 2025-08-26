{%- macro build_append_only_sql(target_relation, temp_relation) -%}

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
    
    {%- set columns = adapter.get_columns_in_relation(target_relation) -%}
    {%- set csv_colums = get_quoted_csv(columns | map(attribute="name")) %}
    {{ create_table_as(True, temp_relation, sql) }}    
    {{ create_table_as(True, temp_relation, sql) }}
    INSERT INTO {{ target_relation }} ({{ csv_colums }})
    SELECT DISTINCT
    B.snap_datetime as snap_datetime,A.*
        FROM
          {{ temp_relation }} A, {{ref('stg_snap_datetime')}} B
{%- endmacro -%}