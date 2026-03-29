# lex-lex: Extension Registry for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-core/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Core Legion Extension that persists extension, runner, and function metadata to the database. When LEX gems load, `LegionIO` publishes a `LexRegister` message to RabbitMQ. This extension consumes those messages and writes the catalog to `legion-data` models. Also provides a sync runner that reconciles in-memory extension state with the database on startup. Includes an `AgentWatcher` actor that hot-reloads YAML agent definitions when their source files change.

Without lex-lex, the extensions/runners/functions DB tables remain empty, and the REST API, MCP tools, and CLI commands that query extension metadata return stale results.

**GitHub**: https://github.com/LegionIO/lex-lex
**License**: MIT
**Version**: 0.3.3

## Architecture

```
Legion::Extensions::Lex
├── Runners/
│   ├── Extension    # CRUD on Legion::Data::Model::Extension
│   ├── Runner       # CRUD on Legion::Data::Model::Runner
│   ├── Function     # CRUD on Legion::Data::Model::Function + arg schema building
│   ├── Register     # Orchestration: persist full extension descriptor from LexRegister message
│   └── Sync         # Reconcile in-memory @extensions with DB (guarded by Data.connected?)
└── Actor/           # Note: singular "Actor" per framework convention
    ├── Sync         # Once actor: fires 5s after startup, calls Sync.sync
    └── AgentWatcher # Every 30s: checks mtime of loaded YAML agent definition files,
                     # triggers hot-reload via Legion::Extensions.load_yaml_agents
                     # when any file is modified. Overrides runner_class to self.class;
                     # use_runner? false (calls action directly, bypasses Runner.run)
```

## Data Flow

```
Extension loads (LegionIO/lib/legion/extensions.rb)
  -> Publishes LexRegister message (routing key: extension_manager.register.save)
  -> RabbitMQ queue "lex.register" (defined in lex-tasker)
  -> lex-lex Subscription actor consumes message
  -> Register.save persists extension + runners + functions to DB

Startup (after all extensions load):
  -> Sync Once actor fires (5s delay)
  -> Reads Legion::Extensions.@extensions and @loaded_extensions
  -> Creates/updates DB records to match in-memory state

Runtime:
  -> AgentWatcher Every actor (30s)
  -> Compares File.mtime of each YAML agent source file to stored _source_mtime
  -> If any file changed, nullifies @load_yaml_agents cache and calls load_yaml_agents
```

## Key Design Decisions

- **Direct DB calls**: Register.save calls Extension/Runner/Function modules directly instead of going through `Legion::Runner.run`. Registration is infrastructure plumbing, not business logic — task tracking overhead is unnecessary.
- **Idempotent**: All create methods check for existing records and update instead of duplicating.
- **Guard on sync**: Sync runner checks `Legion::Settings[:data][:connected]` before any DB operations.
- **data_required?**: Set to `true` — extension will not load if `legion-data` is unavailable.
- **AgentWatcher**: overrides `runner_class` to `self.class` — required for self-contained actors that call `action` directly. Without this, the framework would try to resolve `Runners::AgentWatcher`.

## File Map

| Path | Purpose |
|------|---------|
| `lib/legion/extensions/lex.rb` | Entry point, requires all runners; conditionally requires AgentWatcher |
| `lib/legion/extensions/lex/version.rb` | VERSION constant (0.3.3) |
| `lib/legion/extensions/lex/runners/extension.rb` | Extension CRUD |
| `lib/legion/extensions/lex/runners/runner.rb` | Runner CRUD |
| `lib/legion/extensions/lex/runners/function.rb` | Function CRUD + build_args |
| `lib/legion/extensions/lex/runners/register.rb` | Orchestration: full extension registration |
| `lib/legion/extensions/lex/runners/sync.rb` | In-memory to DB reconciliation |
| `lib/legion/extensions/lex/actors/sync.rb` | Once actor for startup sync |
| `lib/legion/extensions/lex/actors/agent_watcher.rb` | Every actor for YAML agent hot-reload |

## Testing

```bash
bundle install
bundle exec rspec     # 71+ specs, 0 failures
bundle exec rubocop   # 0 offenses
```

Specs run standalone without the full Legion framework. The spec_helper provides in-memory stubs for `Legion::Data::Model::*`, `Legion::Settings`, `Legion::Extensions::Helpers::Lex`, and `Legion::JSON`.

---

**Maintained By**: Matthew Iverson (@Esity)
