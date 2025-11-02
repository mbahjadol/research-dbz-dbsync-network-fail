# SQLServer to SQLServer

data flow with SQLServer as source connector and MySQL as sink connector examples.

[<< Back to dbz-check-test Root](../README.md)

## Table of Contents

* [Topology](#topology)
    * [Usage](#usage)
        * [Running](#running)
          * [Testing](#testing)         
        * [Stopping](#stopping)

---

### Specifications

  SQLServer version 2019
  FROM mcr.microsoft.com/mssql/server:2019-latest

---

### Topology


#### Synchronize Topology

```
                +-----------------+
                |                 |
                |    SQLServer    |
                |                 |
                +---------+-------+
                          |
                          |
                          |
          +---------------v------------------+
          |                                  |
          |           Kafka Connect          |
          |  (Debezium, JDBC connectors)     |
          |                                  |
          +---------------+------------------+
                          |
                          |
                          |
                          |
                  +-------v--------+
                  |                |
                  |   SQLServer    |
                  |                |
                  +----------------+


```

We are using Docker Compose to deploy following components
* SQLServer
* Kafka
  * ZooKeeper
  * Kafka Broker
  * Kafka Connect with [Debezium](https://debezium.io/) and  [JDBC](https://debezium.io/documentation/reference/stable/connectors/jdbc.html) Connectors
* SQLServer


#### Real-time Monitoring Topology

```
+---------------------+        +---------------------+
|  Source SQL Server  |        |  Target SQL Server  |
|  (CDC enabled)      |        |  (Debezium sink)    |
+----------+----------+        +----------+----------+
           |                              ^
           |                              |
           v                              |
+---------------------+        +------------------------+
|   Debezium Connect  | -----> |     Kafka Broker       |
|  (JMX metrics open) |        |  (JMX + KafkaExporter) |
+---------------------+        +------------------------+
                |                       |
                +-----> Prometheus <----+
                            |
                            v
                        Grafana
```

##### 🧭 Goal

Add real-time monitoring for:
* Kafka consumer lag
* Debezium connector lag
* SQL Server sync latency
* System health (Kafka, Connect, Zookeeper)

Using:
* Prometheus — metrics collector
* Grafana — visualization dashboard
* Kafka Exporter — exports consumer lag metrics
* JMX Exporter — exports JVM metrics from Kafka & Connect


---

### Usage
All of the environment setting is stored at env.sh, you can look at there.
👉 Grafana UI: http://localhost:3000
(default login: admin / admin)

#### Running
All processed is almost automatically from creating container setup the connector until you can testing the flow you can only running single command and then you can follow the instruction there.

How to run:

```shell
cd sqlsvr_sqlsvr

# Starting up
./start.sh

```


#### Testing

You can follow the instruction there, which test adding, modify, and deletion test.


#### Stopping
How to stop:

```shell
# Stopping 
./stop.sh

```




[<< Back to dbz-check-test Root](../README.md)