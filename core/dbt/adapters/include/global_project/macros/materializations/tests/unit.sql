{%- materialization unit, default -%}

  {% set relations = [] %}

  {% set expected_rows = config.get('expected_rows') %}
  {% set tested_expected_column_names = expected_rows[0].keys() if (expected_rows | length ) > 0 else get_columns_in_query(sql) %} %}

  {%- set target_relation = this.incorporate(type='table') -%}
  {%- set temp_relation = make_temp_relation(target_relation)-%}
  {% do run_query(get_create_table_as_sql(True, temp_relation, get_empty_subquery_sql(sql))) %}
  {%- set columns_in_relation = adapter.get_columns_in_relation(temp_relation) -%}
  {%- set column_name_to_data_types = {} -%}
  {%- for column in columns_in_relation -%}
  {%- do column_name_to_data_types.update({column.name: column.dtype}) -%}
  {%- endfor -%}

  {% set unit_test_sql = get_unit_test_sql(sql, get_expected_sql(expected_rows, column_name_to_data_types), tested_expected_column_names) %}

  {% call statement('main', fetch_result=True) -%}

    {{ unit_test_sql }}

  {%- endcall %}

  {% do adapter.drop_relation(temp_relation) %}

  {{ return({'relations': relations}) }}

{%- endmaterialization -%}
