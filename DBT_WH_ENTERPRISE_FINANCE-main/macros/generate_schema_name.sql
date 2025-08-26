{% macro generate_schema_name(custom_schema_name, node) -%}
{% set query_tag = {} %}
    {%- do query_tag.update(
        PROJECT_NAME=project_name,  
        BU='ZDI',
        app='dbt', 
        dbt_snowflake_query_tags_version='2.5.0',
        thread_id=thread_id
    ) -%}
{% set query_tag_json = tojson(query_tag) %}
{% do run_query("alter session set query_tag = '{}'".format(query_tag_json)) %}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}