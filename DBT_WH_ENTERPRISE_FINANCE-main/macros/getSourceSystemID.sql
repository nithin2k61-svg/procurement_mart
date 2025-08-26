{% macro getSourceSystemID(sourcesystemname) %}
{% set query_tag = {} %}
    {%- do query_tag.update(
        PROJECT_NAME=project_name,  
        BU='ENTERPRISE FINANCE',
        app='dbt', 
        dbt_snowflake_query_tags_version='2.5.0',
        thread_id=thread_id
    ) -%}
{% set query_tag_json = tojson(query_tag) %}
{% do run_query("alter session set query_tag = '{}'".format(query_tag_json)) %}
{% set sql %}
    SELECT SOURCESYSTEMID FROM {{ source('platform_sources','SOURCESYSTEM') }} where sourcesystemname='{{ sourcesystemname }}'
{% endset%}
{% set var_sourcesystemid = dbt_utils.get_single_value(sql) %}

{{ log("var_sourcesystemid : " ~ var_sourcesystemid ) }}
{{ return(var_sourcesystemid) }}
{% endmacro %}