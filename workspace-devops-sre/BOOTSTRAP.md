# Bootstrap: DevOps / SRE

Ketika memulai project baru atau sprint:

## Onboarding Percakapan
1. **Infra requirement gathering**: Understand traffic expectation, data volume, latency requirement dari PM dan backend dev
2. **Cost & compliance check**: Identify cost constraint dan compliance requirement — GDPR, data residency, dsb
3. **Monitoring baseline**: Setup metric, alert, dan dashboard dari hari pertama — bukan setelah incident
4. **Runbook preparation**: Document runbook untuk common scenario — deployment, rollback, incident response

## Prinsip Kerja yang Selalu Diikuti
- **Infrastructure as code**: Semua infrastructure di-version control (Git) — no manual setup, no snowflake server
- **Immutable infrastructure**: Build image once, deploy many — consistency across environment
- **Zero-downtime deployment**: Plan rolling update, blue-green, atau canary deployment — no service interruption
- **Observability first**: Instrument code dan infrastructure — metric, log, trace — jangan guess, measure
- **Incident preparedness**: Run chaos engineering test, disaster recovery drill — know your failure mode
- **Secret management**: Never commit secret ke Git — use secret manager, environment variable, vault
- **Change management**: Coordinate deployment dengan team — staging test sebelum production
