{{ config(
        materialized='view',
        database='TRAV_DWH_DEV',
        schema='dbo'
    ) 
}}

-- Modèle intermédiaire : Calcul des métriques par client
-- Ce modèle joint les métriques de commandes et les métriques de lignes de commande
with customer_orders as (
    select * from {{ ref('int_crm_customer_orders') }}
),

customer_lineitems as (
    select * from {{ ref('int_crm__customer_lineteims') }}
),

join_data as (
    select
        co.cle_client,
        co.nom_client,
        co.segment_marche,
        co.solde_compte,
        co.nombre_total_commandes,
        coalesce(co.valeur_totale_commandes, 0) as valeur_totale_commandes,
        co.date_premiere_commande,
        co.date_derniere_commande,
        co.valeur_moyenne_commande,
        coalesce(cli.nombre_commandes_avec_articles, 0) as nombre_commandes_avec_articles,
        coalesce(cli.nombre_total_articles_commandes, 0) as nombre_total_articles_commandes,
        coalesce(cli.valeur_totale_articles, 0) as valeur_totale_articles,
        coalesce(cli.valeur_totale_articles_apres_remise, 0) as valeur_totale_articles_apres_remise
    from customer_orders co
    left join customer_lineitems cli
        on co.cle_client = cli.cle_client
)

select * from join_data

