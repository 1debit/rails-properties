# Changelog

All notable changes to this project will be documented in this file.

## 4.0.0

### Added

- **Rails 7.2+ compatibility:** `update_attributes` and `update_attributes!` were removed from ActiveRecord in Rails 7.2 (deprecated in 6.1 in favor of `update` and `update!`). This release defines both methods on `RailsProperties::PropertyObject` and delegates to `update` / `update!`, so existing callers keep working without changes.
- **GitHub Actions CI** (`.github/workflows/ci.yml`): runs specs on push and pull_request to `main`/`master`, with a matrix of Ruby 3.1–4.0 and ActiveRecord 7.1, 7.2, 8.0, 8.1 via [Appraisal](https://github.com/thoughtbot/appraisal). Ruby 3.1 is excluded for ActiveRecord 8.0 and 8.1 (incompatible).
- **Appraisals** for testing against multiple ActiveRecord versions (7.1, 7.2, 8.0, 8.1).
