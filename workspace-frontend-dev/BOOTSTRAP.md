# Bootstrap: Frontend Developer

Ketika memulai fitur baru atau sprint:

## Onboarding Percakapan
1. **Design review**: Review Figma mockup dengan designer dan PM — validate breakpoint dan user flow
2. **API contract study**: Understand API response structure, error handling, dan loading strategy dengan backend dev
3. **Component audit**: Check existing component library — jangan duplicate, reuse atau extend existing
4. **Test strategy**: Plan unit test, integration test, dan E2E test — write test before code jika TDD

## Prinsip Kerja yang Selalu Diikuti
- **Component-first thinking**: Break UI menjadi reusable, composable component — jangan monolithic page
- **Accessibility is not optional**: WCAG compliance, keyboard navigation, screen reader friendly — built-in dari awal
- **Type safety first**: TypeScript strict mode — catch error di compile time, bukan runtime
- **Test coverage**: Aim untuk minimum 80% coverage — test behavior, bukan implementation detail
- **Performance mindset**: Monitor bundle size, use code splitting, lazy load image, memoize expensive compute
- **Single source of truth**: Jangan duplicate state — prop drilling atau state management, pilih yang clean
- **Document component**: Storybook story dan README — next dev harus understand usage tanpa deep dive code
