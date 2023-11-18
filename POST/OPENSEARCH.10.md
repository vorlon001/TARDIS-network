```

node.attr.temp: hot
node.attr.temp: warm
node.attr.temp: cold

node.roles: [ search ]
node.roles: [“dynamic”]


opensearch-data-hot
opensearch-data-warm
opensearch-data-cold


{% if inventory_hostname in groups['opensearch-data-hot'] %}node.attr.temp: hot{% endif %}
{% if inventory_hostname in groups['opensearch-data-warm'] %}node.attr.temp: warm{% endif %}
{% if inventory_hostname in groups['opensearch-data-cold'] %}node.attr.temp: cold{% endif %}



https://opensearch.org/docs/latest/tuning-your-cluster/index/

Nodes
The following table provides brief descriptions of the node types:

Node type       Description     Best practices for production:

Cluster manager
    - Manages the overall operation of a cluster and keeps track of the cluster state. This includes creating and deleting indexes, keeping track of the nodes that join and leave the cluster, checking the health of each node in the cluster (by running ping requests), and allocating shards to nodes.      Three dedicated cluster manager nodes in three different zones is the right approach for almost all production use cases. This configuration ensures your cluster never loses quorum. Two nodes will be idle for most of the time except when one node goes down or needs some maintenance.

Cluster manager eligible
    - Elects one node among them as the cluster manager node through a voting process.        For production clusters, make sure you have dedicated cluster manager nodes. The way to achieve a dedicated node type is to mark all other node types as false. In this case, you have to mark all the other nodes as not cluster manager eligible.
Data 
    - Stores and searches data. Performs all data-related operations (indexing, searching, aggregating) on local shards. These are the worker nodes of your cluster and need more disk space than any other node type.     As you add data nodes, keep them balanced between zones. For example, if you have three zones, add data nodes in multiples of three, one for each zone. We recommend using storage and RAM-heavy nodes.

Ingest 
    - Pre-processes data before storing it in the cluster. Runs an ingest pipeline that transforms your data before adding it to an index.    If you plan to ingest a lot of data and run complex ingest pipelines, we recommend you use dedicated ingest nodes. You can also optionally offload your indexing from the data nodes so that your data nodes are used exclusively for searching and aggregating.

Coordinating 
    -  Delegates client requests to the shards on the data nodes, collects and aggregates the results into one final result, and sends this result back to the client. A couple of dedicated coordinating-only nodes is appropriate to prevent bottlenecks for search-heavy workloads. We recommend using CPUs with as many cores as you can.
Dynamic 
    - Delegates a specific node for custom work, such as machine learning (ML) tasks, preventing the consumption of resources from data nodes and therefore not affecting any OpenSearch functionality.

Search 
    - Provides access to searchable snapshots. Incorporates techniques like frequently caching used segments and removing the least used data segments in order to access the searchable snapshot index (stored in a remote long-term storage source, for example, Amazon S3 or Google Cloud Storage).    Search nodes contain an index allocated as a snapshot cache. Thus, we recommend dedicated nodes with a setup with more compute (CPU and memory) than storage capacity (hard disk).



curl -XGET https://192.168.200.140:9200/_cluster/stats -u admin:admin --insecure
curl -XGET https://192.168.200.140:9200/_cat/templates -u admin:admin --insecure
curl -H 'Content-Type: application/json' -X PUT \
    -d '{"persistent":{"cluster.max_shards_per_node": 5000}}' \
     https://192.168.200.140:9200/_cluster/settings -u admin:admin --insecure | jq .


curl -H 'Content-Type: application/json' -X PUT \
    -d '{"persistent":{"action.auto_create_index": true}}' \
     https://192.168.200.140:9200/_cluster/settings -u admin:admin --insecure | jq .

curl -H 'Content-Type: application/json' -X PUT \
    -d '{"template" : "cloud*", "settings" : {"number_of_shards": 2,"number_of_replicas" : 2 }}' \
     https://192.168.200.140:9200/_template/lma_template -u admin:admin --insecure | jq .

curl -H 'Content-Type: application/json' -X PUT \
     -d '{"template" : "tests*", "settings" : {"number_of_shards": 1,"number_of_replicas" : 1 ,"index.routing.allocation.require.temp": "hot"}}' \
      https://192.168.200.140:9200/_template/tests -u admin:admin --insecure | jq .

curl -H 'Content-Type: application/json' -X PUT \
     -d '{"persistent": { "cluster.routing.allocation.disk.watermark.low": "3gb", "cluster.routing.allocation.disk.watermark.high": "2gb", "cluster.routing.allocation.disk.watermark.flood_stage": "1gb","cluster.info.update.interval": "1m"}}' \
     https://192.168.200.140:9200/_cluster/settings -u admin:admin --insecure | jq .
     
curl -XGET "https://192.168.200.140:9200/_cat/nodeattrs?v&h=node,attr,value" -u admin:admin --insecure

curl -XGET https://192.168.200.140:9200/_cat/nodes?v -u 'admin:admin' --insecure

curl -XPUT "https://192.168.200.140:9200/_plugins/_ism/policies/hot_warm_test" -H 'Content-Type: application/json' -d'
{
  "policy": {
      "policy_id": "hot_warm_test",
      "description": "Shards moving across nodes test",
      "last_updated_time": 1696066832034,
      "schema_version": 19,
      "error_notification": null,
      "default_state": "hot",
      "states": [
          {
              "name": "hot",
              "actions": [],
              "transitions": [
                  {
                      "state_name": "warm",
                      "conditions": {
                          "min_index_age": "1d"
                      }
                  },
                  {
                      "state_name": "warm",
                      "conditions": {
                          "min_doc_count": 100
                      }
                  },
                  {
                      "state_name": "warm",
                      "conditions": {
                          "min_size": "1gb"
                      }
                  }
              ]
          },
          {
              "name": "warm",
              "actions": [
                  {
                      "retry": {
                          "count": 3,
                          "backoff": "exponential",
                          "delay": "1m"
                      },
                      "replica_count": {
                          "number_of_replicas": 1
                      }
                  },
                  {
                      "retry": {
                          "count": 3,
                          "backoff": "exponential",
                          "delay": "1m"
                      },
                      "allocation": {
                          "require": {
                              "temp": "warm"
                          },
                          "include": {},
                          "exclude": {},
                          "wait_for": false
                      }
                  }
              ],
              "transitions": [
                  {
                      "state_name": "cold",
                      "conditions": {
                          "min_index_age": "2d"
                      }
                  },
                  {
                      "state_name": "cold",
                      "conditions": {
                          "min_doc_count": 300
                      }
                  },
                  {
                      "state_name": "delete",
                      "conditions": {
                          "min_size": "2gb"
                      }
                  }
              ]
          },
          {
              "name": "cold",
              "actions": [
                  {
                      "retry": {
                          "count": 3,
                          "backoff": "exponential",
                          "delay": "1m"
                      },
                      "replica_count": {
                          "number_of_replicas": 1
                      }
                  },
                  {
                      "retry": {
                          "count": 3,
                          "backoff": "exponential",
                          "delay": "1m"
                      },
                      "allocation": {
                          "require": {
                              "temp": "cold"
                          },
                          "include": {},
                          "exclude": {},
                          "wait_for": false
                      }
                  }
              ],
              "transitions": [
                  {
                      "state_name": "delete",
                      "conditions": {
                          "min_doc_count": 500
                      }
                  },
                  {
                      "state_name": "delete",
                      "conditions": {
                          "min_index_age": "3d"
                      }
                  },
                  {
                      "state_name": "delete",
                      "conditions": {
                          "min_size": "5gb"
                      }
                  }
              ]
          },
          {
              "name": "delete",
              "actions": [
                  {
                      "retry": {
                          "count": 3,
                          "backoff": "exponential",
                          "delay": "1m"
                      },
                      "delete": {}
                  }
              ],
              "transitions": []
          }
      ],
      "ism_template": [
          {
              "index_patterns": [
                  "datalogs-hotwarm"
              ],
              "priority": 999,
              "last_updated_time": 1696019194773
          },
          {
              "index_patterns": [
                  "tests*"
              ],
              "priority": 50,
              "last_updated_time": 1696055903957
          }
      ]
  }
}'  -u admin:admin --insecure



```
