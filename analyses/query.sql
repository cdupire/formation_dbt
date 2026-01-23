with 
customer_orders as (
    select c.c_custkey as cle_client, c.c_name as nom_client,
        c.c_mktsegment as segment_marche, c.c_acctbal as solde_compte,
        count(distinct o.o_orderkey) as nombre_total_commandes,
        sum(o.o_totalprice) as valeur_totale_commandes,
        min(o.o_orderdate) as date_premiere_commande,
        max(o.o_orderdate) as date_derniere_commande,
        avg(o.o_totalprice) as valeur_moyenne_commande
    from ODS_DWH_DEV.ERP.CUSTOMER c
        left join ODS_DWH_DEV.ERP.ORDERS o on c.c_custkey = o.o_custkey
    group by c.c_custkey, c.c_name, c.c_mktsegment, c.c_acctbal
),
customer_lineitems as (
select  o.o_custkey as cle_client,
        count(distinct li.l_orderkey) as nombre_commandes_avec_articles,
        sum(li.l_quantity) as nombre_total_articles_commandes,
        sum(li.l_extendedprice) as valeur_totale_articles,
        sum(li.l_extendedprice * (1 - li.l_discount)) as valeur_totale_articles_apres_remise
    from ODS_DWH_DEV.ERP.ORDERS o
        inner join ODS_DWH_DEV.ERP.LINEITEM li on o.o_orderkey = li.l_orderkey
    group by o.o_custkey
)
select
        co.cle_client, co.nom_client, co.segment_marche, co.solde_compte,
        co.nombre_total_commandes, co.valeur_totale_commandes,
        co.date_premiere_commande, co.date_derniere_commande, co.valeur_moyenne_commande,
        coalesce(cli.nombre_commandes_avec_articles, 0) as nombre_commandes_avec_articles,
        coalesce(cli.nombre_total_articles_commandes, 0) as nombre_total_articles_commandes,
        coalesce(cli.valeur_totale_articles, 0) as valeur_totale_articles,
        coalesce(cli.valeur_totale_articles_apres_remise, 0) as valeur_totale_articles_apres_remise
    from customer_orders co
    left join customer_lineitems cli on co.cle_client = cli.cle_client;