{{ config(
    enabled = true, 
    pre_hook="set session query_max_run_time='10m'",
     materialized='table',
    table_type='iceberg',
    properties= {
      "format": "'PARQUET'",
      "partitioning": "ARRAY['event_date']",
    }
    
) }}


with source as (

    select * from {{ source('raw', 'taxi_table') }}   TABLESAMPLE BERNOULLI (20)

),
  source_dup as (

    select * from source TABLESAMPLE BERNOULLI (50)

),
all_events as(
    
        select * from source
        union all
        select * from source_dup
),

final as (

    select

        vendorid,
        cast((tpep_pickup_datetime) as timestamp (6) with time zone)
            as tpep_pickup_datetime,
        cast((tpep_dropoff_datetime) as timestamp (6) with time zone)
            as tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        ratecodeid,
        store_and_fwd_flag,
        pulocationid,
        dolocationid,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        congestion_surcharge,
        airport_fee,
        date( cast( date_trunc('day', tpep_pickup_datetime ) as timestamp (6) )) as event_date


    from all_events


)

select * from final
