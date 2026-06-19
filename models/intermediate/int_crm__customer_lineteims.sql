{{ config(
        materialized='view',
        database='TRAV_DWH_DEV',
        schema='dbo'
    ) 
}}

-- Modèle intermédiaire : Jointure des commandes avec les lignes de commande pour calculer les métriques par client
with orders as (
    select * from {{ ref('stg_erp__orders') }}
),

lineitems as (
    select * from {{ ref('stg_erp__lineteim') }}
),

join_data as (
    select
        o.o_custkey as cle_client,
        count(distinct li.l_orderkey) as nombre_commandes_avec_articles,
        sum(li.l_quantity) as nombre_total_articles_commandes,
        sum(li.l_extendedprice) as valeur_totale_articles,
        sum(li.l_extendedprice * (1 - li.l_discount)) as valeur_totale_articles_apres_remise
    from orders o
    inner join lineitems li
        on o.o_orderkey = li.l_orderkey
    group by o.o_custkey
)

select * from join_data

