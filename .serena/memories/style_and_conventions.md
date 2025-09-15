Code layout: src/ layout with package `sasuke_short` and `scripts/` for CLIs.
Naming: snake_case for functions/variables; PascalCase for classes; modules/packages snake_case.
Typing: Add type hints everywhere except quick one-off scripts; enable mypy (warn-redundant-casts, warn-return-any).
Docstrings: Google style; concise examples; Japanese examples allowed where clearer.
Formatting: ruff format (line length 100); import order via ruff-isort (stdlib, third-party, local).
Error handling: Fail fast in library code; surface user-friendly messages in CLIs.
Logging: Use structured logs; avoid print in library code.
Testing: pytest unit tests per module; mark slow/network with pytest markers.
Commits: Conventional Commits (feat, fix, chore, docs, refactor, test, build, ci, perf, style).
Branches: feature/<short-topic>; use small PRs.
Folders:
- `src/sasuke_short/core` (prompt templates, scoring, clustering)
- `src/sasuke_short/io` (ingest/export: csv, notion)
- `src/sasuke_short/cli` (Typer app entry)
- `scripts/` (task-focused scripts)
- `tests/` (mirrors src)
Docs: Keep `README.md` light; add `prompts/` with YAML+Jinja examples.