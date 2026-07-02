--- Utils for generating additional info on mismatched cols for row based audit ---

{# 
  Takes list of column names and returns list of same column names wrapped in 'array_agg()' 
  e.g. 'col_name' -> 'array_agg(col_name) as col_name' 
#}
{% macro aggregate_cols(col_list) %}
  
  {% set return_cols = [] %}

  {% for col in col_list %}
    {% do return_cols.append("array_agg(" ~ col ~ ") as " ~ col) %}
  {% endfor %}

  {{ return(
    return_cols 
    | join(',\n')
  )}}
{%- endmacro %}


{# 
  Takes list of of column names (assumed to be array-like) and returns list of 
  expressions to detect mismatch between 1st and 2nd array element
  e.g. 'col_name' -> 'col_name[1] is distinct from col_name[2] as mismatch_col_name' 
#}
{% macro mismatched_cols(col_list) %}

  {% set return_cols = [] %}

  {% for col in col_list %}
    {% do return_cols.append(col ~ "[1] is distinct from " ~ col ~ "[2] as " ~ col ~ "_mismatch") %}
  {% endfor %}

  {{ return(
    return_cols 
    | join(',\n')
  )}}
{%- endmacro %}