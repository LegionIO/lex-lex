# Changelog

## [0.2.1] - 2026-03-17

### Fixed
- Remove debug `false` return in Sync actor `enabled?` that prevented sync from ever running

## [0.2.0] - 2026-03-14

### Added
- Sync runner: reconciles in-memory extensions with database on startup
- Sync Once actor: fires 5s after startup, guarded by `Legion::Data.connected?`
- Nil guards on all CRUD operations (return `{ success: false }` instead of raising)
- Comprehensive spec suite (55 specs)

### Changed
- Modernized to Ruby >= 3.4
- Register.save uses direct module calls instead of `Legion::Runner.run` chain
- Register.save is now an instance method (was `self.save`)
- Updated gemspec: GitHub URLs, rubygems_mfa_required, modern dev dependencies
- Updated rubocop config to match current LegionIO conventions
- All runners guard `include Legion::Extensions::Helpers::Lex` with `defined?` check

### Removed
- Bitbucket pipeline config
- Docker deployment script
- Old Dockerfile

## [0.1.3] - Legacy

- Original Bitbucket-era release
- Ruby 2.5 minimum
- Extension/Runner/Function CRUD via `Legion::Runner.run` chain
