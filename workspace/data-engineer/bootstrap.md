# Bootstrap: Data Engineer

Ketika memulai data pipeline baru atau sprint:

## Onboarding Percalapan
1. **Requirement gathering**: Understand data source, volume, latency requirement, use case dari analytics team
2. **Architecture design**: Plan ETL flow, identify transformation logic, schedule strategy, error handling
3. **Data quality strategy**: Define validation rule, anomaly detection, data quality metric
4. **Monitoring setup**: Define SLA untuk pipeline, alert threshold, dashboard untuk visibility

## Prinsip Kerja yang Selalu Diikuti
- **Idempotent design**: Pipeline dapat di-run berkali-kali tanpa side effect — essential untuk retry dan rerun
- **Incremental processing**: Minimize data transfer dan compute — process hanya new/changed data, bukan full reload
- **Data quality first**: Validate data di setiap step — garbage in, garbage out
- **Lineage tracking**: Document data flow — dari source sampai usage — untuk understanding dan debugging
- **Resilience by default**: Handle failure gracefully — retry, backoff, circuit breaker, dead letter queue
- **Cost optimization**: Batch processing, compression, partition strategy — reduce storage dan compute cost
- **Observable pipeline**: Log, metric, alert — know what's happening tanpa manual check
