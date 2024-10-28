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
        ref('taxi_with_dup') , 
        ['tpep_pickup_datetime', 'tpep_dropoff_datetime', 'vendorid', 'trip_distance'],
        'event_date' 
        )
    }}

)

select * from import_cte

 
