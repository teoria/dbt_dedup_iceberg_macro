{{ config(
    enabled = true,
    materialized='table',
    table_type='iceberg',
    properties= {
      "format": "'PARQUET'",
      "partitioning": "ARRAY['my_date']",
    }
) }}

select
    'A' as user_id,
    'pi' as name,
    'active' as status,
    17.89 as cost,
    1 as quantity,
    100000000 as quantity_big,
    '2020-01-01' as my_date
union distinct
select
    'B' as user_id,
    'pi' as name,
    'active' as status,
    17.89 as cost,
    1 as quantity,
    100000000 as quantity_big,
    '2020-01-02' as my_date
union all
select
    'A' as user_id,
    'pi' as name,
    'active' as status,
    17.89 as cost,
    1 as quantity,
    100000000 as quantity_big,
    '2020-01-01' as my_date
