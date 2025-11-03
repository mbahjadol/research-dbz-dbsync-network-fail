# SQLServer 2019 to SQLServer 2019

data flow with SQLServer 2019 as source connector and SQLServer 2019  as sink connector examples.

[<< Back to Root](../README.md)

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

## Topology & Architecture Design


### 1. Synchronize Topology

```
                +-----------------+
                |                 |
                |    SQLServer    |
                |      2019       |
                +---------+-------+
                          |
                          |
                          |
          +---------------v------------------+
          |                                  |
          |           Kafka Connect          |
          | (Debezium, JDBC connectors, etc) |
          |                                  |
          +---------------+------------------+
                          |
                          |
                          |
                          |
                  +-------v--------+
                  |                |
                  |   SQLServer    |
                  |      2019      |
                  +----------------+


```

We are using Docker Compose to deploy following components
* SQLServer
* Kafka
  * ZooKeeper
  * Kafka Broker
  * Kafka Connect with [Debezium](https://debezium.io/) and  [JDBC](https://debezium.io/documentation/reference/stable/connectors/jdbc.html) Connectors
* SQLServer

---

### 2. Real-time Monitoring Topology

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

##### 🧭 Real-time Monitoring Goal

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

### 3. Segregation Networking Simulation Base on Real World Case

```
           ┌──────────────┐
           │   Grafana    │
           └──────┬───────┘
                  │ {monitor_net}
           ┌──────┴─────────┐
           │  Prometheus    │
           └──────┬─────────┘
                  │
        ┌─────────┼───────────────┐
        │ kafka-exporter          │
        │ connect {bridges all}   │
        └──┬───────┬───────────┬──┘
           │       │           │
 {source_net}  {target_net}   {kafka_net}
      │            │           │
  source-db     target-db     kafka
      │                        │
 {sim_zone}             zookeeper, kafka-ui
      |
   sim-svc     
```

#### Logical Network Zone Design

| Zone         | Network | Purpose                    | Connected Components                                          |
| --------------- | -------------------------- | --------------------------| ------------------------------------------------------------- |
| 🧪 **Sim Zone**     | `sim_zone` | Simulator ↔ Source DB only | `sim-svc`, `source-db`                                        |
| 🛢️ **Source Zone**  | `source_zone` | Connect ↔ Source DB only   | `connect`, `source-db`                                        |
| 🎯 **Target Zone**  | `target_zone` | Connect ↔ Target DB only   | `connect`, `target-db`                                        |
| 🔗 **Kafka Zone**   | `kafka_zone` | Kafka stack                | `connect`, `zookeeper`, `kafka`, `kafka-ui`, `kafka-exporter` |
| 📈 **Monitor Zone** | `monitor_zone` | Monitoring stack           | `connect`, `prometheus`, `grafana`, `kafka-exporter`          |


#### Interconnection Rules

| Source                                     | Destination   | Network(s)                   | Description |
| ------------------------------------------ | ------------- | ---------------------------- | ----------- |
| `sim-svc` → `source-db`                    | `sim_zone`  | For insert/update simulation |             |
| `connect` → `source-db`                    | `source_zone`  | CDC source                   |             |
| `connect` → `target-db`                    | `target_zone`  | JDBC sink                    |             |
| `connect` → `kafka`                        | `kafka_zone`   | Message transport            |             |
| `connect` → `prometheus` (metrics scrape)  | `monitor_zone` | Monitoring                   |             |
| `prometheus` → `kafka-exporter`, `connect` | `monitor_zone` | Metric sources               |             |
| `grafana` → `prometheus`                   | `monitor_zone` | Dashboard                    |             |


---

### Usage

🧰 5. Load Prebuilt Dashboards

In Grafana:
- Add Prometheus data source → URL: http://prometheus:9090
- Import dashboards (via Grafana → Dashboards → Import):
- Kafka Exporter Dashboard (ID: 7589)
- Debezium Connector Dashboard (custom or from community)

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




[<< Back to Root](../README.md)