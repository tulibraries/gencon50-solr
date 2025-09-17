# Gencon 50 Solr Configurations

These are the Solr configuration files for the Gencon50 (Best 50 Years in Gaming) content search & faceting Solr collection.
# TUL COB Catalog Solr Configurations
[![Lint and Test](https://github.com/tulibraries/gencon50-solr/actions/workflows/lint-test.yml/badge.svg)](https://github.com/tulibraries/gencon50-solr/actions/workflows/lint-test.yml)

These are the Solr configuration files for the TUL Cob (LibrarySearch) Alma catalog content search & faceting Solr collection.

## Prerequisites

- These configurations are built for Solr 9
- The instructions below presume a SolrCloud multi-node setup (using an external Zookeeper)

## Local Testing / Development

You need a local SolrCloud cluster running to load these into. For example, use the make commands + docker-compose file in https://github.com/tulibraries/ansible-playbook-solrcloud to start a cluster. That repository's makefile includes this set of configurations and collection (gencon50) in its `make create-release-collections` and `make create-aliases` commands.

If you want to go through those steps yourself, once you have a working SolrCloud cluster:

1. clone this repository locally & change into the top level directory of the repository

```
$ git clone https://github.com/tulibraries/gencon50-solr.git
$ cd gencon50-solr
```

2. zip the contents of this repository *without* the top-level directory

```
$ zip -r - * > gencon50.zip
```

3. load the configs zip file into a new SolrCloud ConfigSet (change the solr url to whichever solr you're developing against)

```
$ curl -X POST --header "Content-Type:application/octet-stream" --data-binary @gencon50.zip "http://localhost:8081/solr/admin/configs?action=UPLOAD&name=gencon50"
```

4. create a new SolrCloud Collection using that ConfigSet (change the solr url to whichever solr you're developing against)

```
$ curl "http://localhost:8090/solr/admin/collections?action=CREATE&name=gencon50-1&numShards=1&replicationFactor=4&maxShardsPerNode=1&collection.configName=gencon50"
```

5. create a new SolrCloud Alias pointing to that Collection (if you want to use an Alias; and change the solr url to whatever solr you're developing against):

```
$ curl "http://localhost:8090/solr/admin/collections?action=CREATEALIAS&name=gencon50-1-dev&collections=gencon50-1"
```

## SolrCloud Deployment

All PRs merged into the `main` branch are _not_ deployed anywhere. Only releases are deployed.

### Production

Once the main branch has been adequately tested and reviewed, a release is cut. Upon creating the release tag (generally just an integer), the following occurs:
1. new ConfigSet of `gencon50-{release-tag}` is created in [Production SolrCloud](https://solrcloud-rocky9.tul-infra.page);
2. new Collection of `gencon50-{release-tag}-init` is created in [Production SolrCloud](https://solrcloud-rocky9.tul-infra.page) w/the requisite ConfigSet (this Collection is largely ignored);
3. a new QA alias of `gencon50-{release-tag}-qa` is created in [Production SolrCloud](https://solrcloud-rocky9.tul-infra.page), pointing to the init Collection;
3. a new Production alias of `gencon50-{release-tag}-prod` is created in [Production SolrCloud](https://solrcloud-rocky9.tul-infra.page), pointing to the init Collection;
4. and, manually, a full reindex DAG is kicked off from Airflow Production to this new gencon50 alias. Upon completion of the reindex, relevant clients are redeployed pointing at their new alias, and *then QA & UAT review occur*.

See the process outlined here: https://github.com/tulibraries/grittyOps/blob/main/services/solrcloud.md

After some time (1-4 days, as needed), the older gencon50 collections are manually removed from Prod SolrCloud.
