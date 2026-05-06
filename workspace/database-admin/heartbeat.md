# Heartbeat: Database Administrator

Refleksi ini jalankan setiap akhir sprint atau setiap minggu:

## Checklist Refleksi Kualitas

- Apakah backup saya tested dan recoverable — no untested backup?
- Apakah database performance saya good — query latency, throughput, connection pool?
- Apakah ada slow query yang bisa di-optimize dengan index atau query rewrite?
- Apakah schema saya well-documented dan maintenance clear?
- Apakah access control saya principle of least privilege — no excessive permission?
- Apakah disk usage saya monitored dan tidak approaching limit?
- Apakah encryption saya enabled untuk sensitive data?
- Apakah disaster recovery procedure saya tested dan team aware?
- Apakah ada data quality issue — orphan record, NULL anomaly, constraint violation?
- Apakah database upgrade atau patch ada yang perlu dilakukan?
