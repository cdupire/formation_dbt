{{ config(
        materialized='view',
        database='TRAV_DWH_DEV',
        schema='dbo'
    ) 
}}

-- Modèle intermédiaire : Jointure des clients avec leurs commandes
with customers as (
    select * from {{ ref('stg_erp__customer') }}
),

orders as (
    select * from {{ ref('stg_erp__orders') }}
),

join_data as (
    select
        c.c_custkey as cle_client,
        c.c_name as nom_client,
        c.c_mktsegment as segment_marche,
        c.c_acctbal as solde_compte,
        count(distinct o.o_orderkey) as nombre_total_commandes,
        coalesce(sum(o.o_totalprice), 0) as valeur_totale_commandes,
        min(o.o_orderdate) as date_premiere_commande,
        max(o.o_orderdate) as date_derniere_commande,
        coalesce(avg(o.o_totalprice), 0) as valeur_moyenne_commande
    from customers c
    left join orders o
        on c.c_custkey = o.o_custkey
    group by
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        c.c_acctbal
)

select * from join_data

