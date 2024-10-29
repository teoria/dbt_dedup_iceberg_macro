# pip install trino

from trino.dbapi import connect 

conn = connect(
    host="localhost",
    port=8080,
    user="userpython", 
)
cur = conn.cursor()  
sql = """ 
CREATE TABLE if not exists hive.default.taxi_table(
   
    VendorID int,
    tpep_pickup_datetime TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP,
    passenger_count double,
    trip_distance double,
    RatecodeID double,
    store_and_fwd_flag VARCHAR,
    PULocationID int,
    DOLocationID int,
    payment_type int,
    fare_amount double,
    extra double,
    mta_tax double,
    tip_amount double,
    tolls_amount DOUBLE,
    improvement_surcharge double,
    total_amount double,
    congestion_surcharge double,
    airport_fee double
)with (
    external_location = 's3://datalake/raw/',
    format = 'PARQUET'
) 

 
"""
cur.execute(sql) 
print('DONE: hive.default.taxi_table created!')