{% macro is_valid_columns_name(table_relation,columns) %}
{% if execute %}
{% set result = run_query('SHOW COLUMNS FROM '~ table_relation.identifier  ) %}  
{% set results_columns = result.columns[0].values()| list %} 
{{ log('results_columns: ' ~ results_columns, info=False) }}
{% for item in columns if item not in results_columns %}
{% do return(false) %}
{% endfor %}
{% do return(true) %}
{% endif %}
{% endmacro %}

{% macro get_partitions(table_name,columns) %}
{% if execute %}
{% set result = run_query('select distinct '~ columns ~ ' from '~  table_name ) %}  
{% set results = result.columns[0].values()| list %}  
{% do return(results) %} 
{% endif %} 
{% endmacro %}


{% macro create_temp_table(table_target) %} 
{%- set temp_identifier = table_target.database| lower ~'.'~table_target.schema| lower ~'.'~table_target.identifier~'_temp' -%}
{{ log('temp_identifier: ' ~ temp_identifier, info=True) }}
{% set SQL %}
    drop table if exists {{ temp_identifier }};
    CREATE TABLE {{ temp_identifier }} AS
    SELECT * FROM {{ table_target| lower }} WITH NO DATA;
   {% endset %}
{{ log('SQL: ' ~ SQL, info=False) }}
{% do run_query(SQL) %}
{{ return(temp_identifier) }}
{% endmacro %}

{% macro remove_temp_table(temp_table) %}
{{ log('temp_table: ' ~ temp_table, info=True) }}
{% set SQL %}
    drop table if exists {{ temp_table }};
  {% endset %}
{{ log('SQL: ' ~ SQL, info=True) }}
{% do run_query(SQL) %}
{% endmacro %}



{% macro get_model_config_values(model_ref) %}
{%- set table_name = model_ref.identifier -%}

{% for node in graph.nodes.values() %} 
{%- set model_name = node.unique_id.split('.')[-1] -%}
{%- if table_name == model_name -%}
{%- set model_config = node.config -%}] 
            {{ return(model_config) }}
{%- endif -%}
{% endfor %}
{% endmacro %}


{% macro deduplicate_iceberg(table_name, key_columns, sort_column = None) %}
{% if execute %}
{{ log('deduplicate_iceberg: ' ~ table_name.indentifier, info=True) }}   

{% set valid_columns = is_valid_columns_name(table_name   ,   key_columns  ) %} 
{{ log('valid_columns: ' ~ valid_columns, info=True) }}   

{% if not valid_columns %}
{{ exceptions.raise_compiler_error("Invalid Columns.") }}
{% endif %}    

{%- set temp_table = create_temp_table( table_name ) -%}
{{ log('temp_table_name: ' ~ temp_table, info=True) }}
{{ log('table_name: ' ~ table_name, info=True) }}

{%- set partitioned_by = get_model_config_values(table_name).get('properties').get('partitioning') -%} 
{% set pattern = modules.re.compile("'(.*)'") %}
{% set matchs = pattern.findall(partitioned_by) %}
{% set loop_partition = [] %}
{%- for item in matchs %}
{%- do loop_partition.append(item) -%}
{%- endfor -%}
    
  
{{ log('>>>'~ loop_partition , info=False) }}
   
{%- set dest_columns = adapter.get_columns_in_relation(temp_table) -%}
{%- set src_columns = adapter.get_columns_in_relation(table_name) -%}
 

{%- set src_columns_quoted = [] -%} 

{%- for col in dest_columns -%}
{%- do src_columns_quoted.append('src.' + col.quoted ) -%}
{% if col.column == loop_partition[0] %}  
{% endif %}
{%- endfor -%}
 


{% set partitions = get_partitions(table_name, loop_partition[0]) %}
{{ log('partitions: ' ~ partitions, info=False) }} 
{% for partition in partitions %}
{{ log('loop partitinon: ' ~  partition ~ ':' ~(loop.index)~ '/' ~ partitions|length , info=True) }}
{%- set SQL_MERGE -%}
MERGE INTO {{ temp_table }} target
   USING (
 
    WITH  
      ranked AS (
      SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY {{ key_columns | join(', ') }} 
{%- if sort_column %}
          ORDER BY {{ sort_column }}
{% endif -%} 
         ) AS row_num
      FROM  {{ table_name }}    
      where  date({{ loop_partition[0] }}) = date( '{{ partition }}' )  
      
    )
    SELECT
      *
    FROM ranked
    WHERE row_num = 1

    ) src
    ON (
          {%- for key in key_columns -%}
            target.{{ key }} = src.{{ key }}
            {{ " and " if not loop.last }}
          {%- endfor -%}
          and   date(src.{{ loop_partition[0] }}) = date( '{{ partition }}' ) 
      )
  
WHEN NOT MATCHED THEN INSERT ({{ src_columns | map(attribute='quoted') | join(', ') }})
         VALUES ({{ src_columns_quoted | join(', ') }})

  {% endset %}
  {{ log(SQL_MERGE, info=False) }}
  {% do run_query(SQL_MERGE) %}
      {% endfor %}
     

    {{ return(temp_table) }}
   {% endif %}
    
{% endmacro %}
