# Changelog

All notable changes to this project will be documented in this file.

## 4.0.0

- **Rails 7.2 compatibility:** `update_attributes` and `update_attributes!` were removed from ActiveRecord in Rails 7.2 (they were deprecated in 6.1 in favor of `update` and `update!`). This release defines both methods on `RailsProperties::PropertyObject` and delegates to `update` / `update!`, so existing callers keep working without changes.
