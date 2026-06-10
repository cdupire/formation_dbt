{{
    config(
        materialized='table',
        database='TRAV_DWH_DEV',
        schema='dbo' 
    )
}}


with 

source as (

    select * from {{ source('erp', 'customer') }}

),

final as (

    select
        c_custkey,
        c_name,
        c_address,
        c_nationkey,
        c_phone,
        c_acctbal,
        c_mktsegment,
        c_comment

    from source

)

select * from final