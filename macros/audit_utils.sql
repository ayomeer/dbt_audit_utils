
{% macro audit_rows_with_col_mismatched(cols_to_compare, ref_audit_rows) %}
WITH agg_cte as (
  SELECT 
    dbt_audit_surrogate_key,
    {{ audit_utils.aggregate_cols(cols_to_compare) }}

  FROM {{ ref_audit_rows }}
  WHERE dbt_audit_row_status = 'modified'
  GROUP BY dbt_audit_surrogate_key
),
mismatched_cols_cte as (
  SELECT
    dbt_audit_surrogate_key as dbt_audit_surrogate_fkey,
    {{ audit_utils.mismatched_cols(cols_to_compare) }}
  FROM agg_cte
)

SELECT 
  row_number() over() as fid,
  dbt_audit_row_status as row_status,
  CASE 
    WHEN dbt_audit_in_a THEN 'old row'
    WHEN dbt_audit_in_b THEN 'new row'
    ELSE 'error'
  END as row_shown,
  *
FROM {{ ref_audit_rows }} as a
LEFT JOIN mismatched_cols_cte as m
  ON m.dbt_audit_surrogate_fkey = a.dbt_audit_surrogate_key
WHERE dbt_audit_row_status <> 'identical'
ORDER BY 
	dbt_audit_row_status,
	dbt_audit_surrogate_key,
	dbt_audit_in_a,
	dbt_audit_in_b
{%- endmacro %}

--- miscellaneous utility macros
{% macro get_datetime_string() -%}
  {{ run_started_at.astimezone(modules.pytz.timezone("Europe/Zurich")).strftime('%Y-%m-%d %H:%M:%S') }}
{%- endmacro%}