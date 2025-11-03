# Research: Debezium Connectivity — Synchronize Database When Network Fails

This project explores how **Debezium** handles data synchronization between source and sink databases during **network disruptions** or **connectivity loss**. The research focuses on analyzing Debezium’s resilience, recovery mechanisms, and strategies for ensuring **eventual consistency** once the connection is restored.

---

## 🧩 Background

In distributed systems, **network instability** can cause replication or synchronization failures. Tools like **Debezium**, built on top of **Apache Kafka**, are designed to ensure reliable Change Data Capture (CDC) even when transient failures occur.

This project aims to:
- Understand how Debezium behaves during a network outage.
- Measure data loss, duplication, and recovery time.
- Explore configuration and architectural patterns that improve reliability.

---

## 🎯 Objectives

1. Simulate network failures between Debezium, Kafka, and the target database.
2. Observe consumer lag event, buffering, delivery, and reconnection behavior.
3. Evaluate whether Debezium guarantees **exactly-once** or **at-least-once** delivery under unstable conditions.
4. Propose possible enhancements or best practices for maintaining synchronization reliability.

---

## 🧠 Research Questions

- What happens to Debezium events when Kafka or the sink database is temporarily unavailable?
- How does Debezium handle offset management during reconnection?
- Can Debezium resume without data loss or duplication after network recovery?
- What configurations (e.g., `max.poll.interval.ms`, `offset.flush.interval.ms`, retries) affect recovery stability?

---

## 🧪 Test Environment / Setup

This test environment is a compilation with modification from 
* [Debezium Check Test](https://github.com/mbahjadol/dbz-check-test)
* [Network Failure Simulation](https://github.com/mbahjadol/two-network-simulation)
* And adaptation and enhancement from this test [Flink CDC MySQL Test](https://github.com/mbahjadol/flink-cdc-mysql-sync)


We start with 2 types of SQL Server Database, which is:
* MS SQL Server 2019
* MS SQL Server 2022

---

## ⚙️ Architecture Overview

```text
[Source DB] → [Debezium Connector] → [Kafka Topic] → [Kafka Connect Sink] → [Target DB]
                                                                          ↑
                                                            (Simulated Network Failure)
```
---

## 🧾 Methodology

1. **Setup baseline** Debezium + Kafka environment.
2. **Insert / Update** simulating auto sample records in source DB with QPS (Query Per Seconds).
3. **Introduce network failure** (between Debezium and Kafka or Kafka and target DB).
4. **Monitor** message flow, connector logs, and offset storage, we enhance it using prometheus and grafana to observing it especially lag by consumer.
5. **Restore connection** and analyze synchronization behavior.
6. **Document** any data inconsistencies or replay issues.

---

## 📊 Metrics Observed

* Kafka **Lag by Consumer Group**
* Kafka **Message in per seconds**
* Kafka **Message in per minute**
* Kafka **Message consume per minute**
* Kafka **Partition per Topic**
* Kafka specific topic we observes is `s1_insert_lag` and `s1_update_lag`

---

## 💡 Findings (Preliminary)

> *THIS IS SUMMARIZES OF MY OBSERVATIONS.*

* **Debezium buffers unsent events until Kafka is reachable again.**
* **Recovery is automatic and data remains consistent.**

---

## 🧭 Possible Improvements

* Use **Kafka persistence with idempotent producers**.
* Enable **Debezium offset storage on durable medium**.
* Configure **retry and backoff strategies** properly.
* Add **monitoring/alerting** via Prometheus or Grafana.
* Consider **outbox pattern** for transactional integrity.

---

## 🧰 Tools & Utilities

* **Docker Compose** for environment orchestration
* **Toxiproxy / tc** for simulating network conditions
* **Prometheus + Grafana** for monitoring latency and throughput
* **jq / kafkacat** for debugging events

---

## 🗂️ Repository Structure

```bash
.
├── 2019/                      # MSSQLServer 2019 Database to MSSQLServer 2019 Database
├── 2022/                      # MSSQLServer 2022 Database to MSSQLServer 2022 Database
└── README.md
```

---

## 🚀 How to Run

```bash
# 1. Start environment
docker compose up -d

# 2. Insert sample data
./scripts/insert_data.sh

# 3. Simulate network failure
./network-sim/disconnect.sh

# 4. Observe logs
docker logs -f debezium-connector

# 5. Restore connection
./network-sim/reconnect.sh
```

---

## 🧾 License

MIT License — feel free to use and adapt for your own research or development purposes.

---

## 📚 References

* [Debezium Documentation](https://debezium.io/documentation/)
* [Kafka Connect Concepts](https://kafka.apache.org/documentation/#connect)
* [Handling Network Failures in Distributed Systems](https://martinfowler.com/articles/patterns-of-distributed-systems/reliability.html)
* [Outbox Pattern](https://microservices.io/patterns/data/transactional-outbox.html)
* [Debezium Check Test](https://github.com/mbahjadol/dbz-check-test)
* [Network Failure Simulation](https://github.com/mbahjadol/two-network-simulation)
* And adaptation and enhancement from this test [Flink CDC MySQL Test](https://github.com/mbahjadol/flink-cdc-mysql-sync)



---

