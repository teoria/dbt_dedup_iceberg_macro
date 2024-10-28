{{
  config(
    materialized = 'table' 
    )
}}

with import_cte as(
    select 
        *
    from
        {{ deduplicate_iceberg(  
            ref('tab'), 
            ['user_id','my_date'], 
            'my_date' 
            )
        }}
)

select * from import_cte

 