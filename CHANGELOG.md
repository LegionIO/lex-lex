# Changelog

## [0.3.5] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.3.4] - 2026-03-29

### Fixed
- Add transport layer with queue bound to Extensions exchange (routing key `extension_manager.register.#`), fixing LexRegister messages being published but never consumed

## [0.3.3] - 2026-03-22

### Changed
- Add runtime dependencies to gemspec: legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport
- Replace hand-rolled stubs in spec_helper with real sub-gem requires (legion-logging, legion-json, legion-settings)

## [0.3.2] - 2026-03-20

### Fixed
- `Actor::AgentWatcher` now overrides `runner_class` to return `self.class`, preventing the framework from attempting to resolve the non-existent `Runners::AgentWatcher` constant

## [0.3.1] - 2026-03-20

### Added
- `Actor::AgentWatcher` — interval actor (every 30s) that detects file modifications to loaded YAML agent definitions and triggers hot-reload via `Legion::Extensions.load_yaml_agents`
- Conditional require of `AgentWatcher` in entry point (only when `Legion::Extensions::Actors::Every` is available)

## [0.3.0] - 2026-03-18

### Fixed
- `data_required?` now correctly overrides Core default (was instance method, framework ignored it)
- Sync runner only increments update counter on actual DB writes
- Sync runner no longer re-enables intentionally disabled extensions
- Register.save guards against nil extension_id after creation failure

### Changed
- Renamed shadowed `update` local variables to `changes` in Extension, Runner, Function modules

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
