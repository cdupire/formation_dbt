{{
    config(
        database='DWH_DEV',
        schema = 'dbo', 
        transient = false,
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'cle_client'
    )
}}

-- Table dimension : Dimension Client
with customer_metrics as (
    select * from {{ ref('int_crm__customer_metrics') }}
),

final as (

    select
        cm.cle_client,
        cm.nom_client,
        cm.segment_marche,
        cm.solde_compte,
        -- Métriques calculées (depuis int_crm__customer_metrics et int_crm__customer_orders)
        cm.nombre_total_commandes,
        cm.valeur_totale_commandes,
        cm.date_premiere_commande,
        cm.date_derniere_commande,
        cm.valeur_moyenne_commande,
        -- Métriques calculées (depuis int_crm__customer_metrics et int_crm__customer_lineitems)
        cm.nombre_commandes_avec_articles,
        cm.nombre_total_articles_commandes,
        cm.valeur_totale_articles,
        cm.valeur_totale_articles_apres_remise,
        -- Champs de métadonnées
        current_timestamp as dbt_loaded_at
    from customer_metrics cm

),

different_in_dim_customer as (
    select d.* from final d
    {% if is_incremental() %}
    left join {{ this }} t on d.cle_client = t.cle_client
    where
        [d.nom_client, d.segment_marche, d.solde_compte, d.nombre_total_commandes, d.valeur_totale_commandes, d.date_premiere_commande, d.date_derniere_commande, d.valeur_moyenne_commande, d.nombre_commandes_avec_articles, d.nombre_total_articles_commandes, d.valeur_totale_articles, d.valeur_totale_articles_apres_remise]
        <>
        [t.nom_client, t.segment_marche, t.solde_compte, t.nombre_total_commandes, t.valeur_totale_commandes, t.date_premiere_commande, t.date_derniere_commande, t.valeur_moyenne_commande, t.nombre_commandes_avec_articles, t.nombre_total_articles_commandes, t.valeur_totale_articles, t.valeur_totale_articles_apres_remise]
    {% endif %}
)

select * from different_in_dim_customer


