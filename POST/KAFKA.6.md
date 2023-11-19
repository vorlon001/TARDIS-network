
https://coralogix.com/blog/create-kafka-topics-in-3-easy-steps/

Create Kafka Topics in 3 Easy Steps
===================================

![Kafka-Top-Consumer-Read](https://coralogix.com/wp-content/uploads/2019/06/Kafka-Top-Consumer-Read-1024x784.png)

Creating a topic in production is an operative task that requires awareness and preparation. In this tutorial, we’ll explain all the parameters to consider when creating a new topic in production.

Setting the partition count and replication factor is required when creating a new Topic and the following choices affect the performance and reliability of your system.

**Create a topic**
```
kafka/bin/kafka-topics.sh --create \
--zookeeper localhost:2181 \
--replication-factor 2 \
--partitions 3 \
--topic unique-topic-name
```

PARTITIONS
----------

Kafka topics are divided into a number of partitions, which contains messages in an unchangeable sequence. Each message in a partition is assigned and identified by its unique offset.

Partitions allow us to split the data of a topic across multiple brokers balance the load between brokers. Each partition can be consumed by only one consumer group, so the parallelism of your service is bound by the number of partition the topic has.

The number of partitions is affected by two main factors, the number of messages and the avg size of each message. In case the volume is high you will need to use the number of brokers as a multiplier, to allow the load to be shared on all consumers and avoid creating a hot partition which will cause a high load on a specific broker. We aim to keep partition throughput up to 1MB per second.

### Set Number of Partitions
```
--partitions [number]
```
REPLICAS
--------

![Kafka-Topic-Producer-writes](https://coralogix.com/wp-content/uploads/2019/06/Kafka-Topic-Producer-writes.png)

Kafka optionally replicates topic partitions in case the leader partition fails and the follower replica is needed to replace it and become the leader. When configuring a topic, recall that partitions are designed for fast read and write speeds, scalability, and for distributing large amounts of data. The replication factor (RF), on the other hand, is designed to ensure a specified target of fault-tolerance. Replicas do not directly affect performance since at any given time, only one leader partition is responsible for handling producers and consumer requests via broker servers.

Another consideration when deciding the replication factor is the number of consumers that your service needs in order to meet the production volume.

### Set Replication Factor (RF)

In case your topic is using keys, consider using RF 3 otherwise, 2 should be sufficient.
```
--replication-factor [number]
```
[Sign Up Today](https://dashboard.eu2.coralogix.com/#/signup)

RETENTION
---------

The time to keep messages in a topic, or the max topic size. Decide according to your use case. By default, the retention will be 7 days but this is configurable.

### Set Retention
```
--config retention.ms=[number]
```
COMPACTION
----------

In order to free up space and clean up unneeded records,  Kafka compaction can delete records based on the date and size of the record. It can also delete every record with identical keys while retaining the most recent version of that record. Key-based compaction is useful for keeping the size of a topic under control, where only the latest record version is important.

### Enable Compaction
```
log.cleanup.policy=compact
```
For an introduction on Kafka, see this [tutorial](https://coralogix.com/blog/a-complete-introduction-to-apache-kafka/).

