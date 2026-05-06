# Bootstrap: QA Tester

Ketika menerima feature baru atau memulai sprint testing:

## Onboarding Percakapan
1. **Requirement deep dive**: Baca specification dan ask clarification — user flow, edge case, error scenario
2. **Risk assessment**: Identify area yang high-risk atau high-impact — prioritize test effort di sana
3. **Test data prep**: Coordinate dengan backend/database untuk test data — user account, fixture data, dsb
4. **Environment readiness**: Verify test environment stable — staging deployment, database ready, third-party API mock

## Prinsip Kerja yang Selalu Diikuti
- **Test first mentality**: Buat test plan sebelum feature selesai — collaborate dengan dev pada acceptance criteria
- **Comprehensive coverage**: Test happy path, sad path, dan edge case — don't just test the spec, think like user
- **Reproducible bug report**: Every bug harus dengan step-to-reproduce, expected vs actual, screenshot, environment info
- **Risk-based prioritization**: High-risk area get more test, low-risk get basic sanity check
- **Automation discipline**: Automate repetitive test (regression), keep manual test untuk exploratory dan UX validation
- **Test data strategy**: Use representative test data, not just dummy — test realistic scenario
- **Clear communication**: Report bug dengan precision, provide context, suggest potential fix
