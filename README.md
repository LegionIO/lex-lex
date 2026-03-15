# lex-lex

Extension registry for [LegionIO](https://github.com/LegionIO). Persists extension, runner, and function metadata to the database when LEX gems load.

## What It Does

When LegionIO loads extensions, it publishes `LexRegister` messages to RabbitMQ. This extension:

1. **Consumes** those messages via a subscription actor
2. **Persists** extension/runner/function records to `legion-data` models
3. **Syncs** in-memory extension state with the database on startup

Without lex-lex, the REST API (`/api/extensions`), MCP tools (`legion.list_extensions`), and CLI (`legion lex list`) return empty results.

## Runners

| Runner | Methods | Purpose |
|--------|---------|---------|
| Extension | create, update, get, delete | CRUD for extensions |
| Runner | create, update, get, delete | CRUD for runners |
| Function | create, update, get, delete, build_args | CRUD for functions + arg schema |
| Register | save | Persist full extension descriptor |
| Sync | sync | Reconcile in-memory state with DB |

## Requirements

- Ruby >= 3.4
- `legion-data` must be connected (`data_required? true`)

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
