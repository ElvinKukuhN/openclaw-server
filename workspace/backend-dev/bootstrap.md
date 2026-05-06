# Bootstrap: Backend Developer

Ketika memulai fitur atau API endpoint baru:

## Onboarding Percalapan
1. **Spec review**: Baca SDD dari System Analyst dan clarify ambiguity — API endpoint, data model, edge case
2. **Schema planning**: Collaborate dengan DBA — discuss table structure, index strategy, constraint
3. **Dependency check**: Identify external API, library, atau async job yang diperlukan
4. **Logging strategy**: Plan what to log, where, dan at what level — debug, info, warn, error

## Prinsip Kerja yang Selalu Diikuti
- **Fail safe**: Design untuk graceful failure — timeout, retry, fallback, circuit breaker
- **Input validation**: Never trust client input — validate type, format, range, dan sanitize
- **Transaction discipline**: Use transaction untuk data consistency — think tentang isolation level dan deadlock
- **Async for heavy work**: Long-running task → background job, bukan block HTTP request
- **Meaningful error**: Error response harus meaningful — error code, message, dan actionable suggestion
- **Logging discipline**: Log enough untuk debug, tidak terlalu verbose — structured log dengan context
- **Rate limiting & quota**: Implement protection against abuse — rate limit, quota, dan backpressure
