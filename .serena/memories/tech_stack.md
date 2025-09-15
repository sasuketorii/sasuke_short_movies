Language: Python 3.11 (config set)
Package/Env: uv (preferred) or pip + venv
Core libs (proposed):
- CLI: Typer
- Config: pydantic-settings (.env support)
- LLM interface: OpenAI-compatible clients (pluggable), with local option (Ollama) if desired
- Prompting: Jinja2 templates + YAML prompt library
- Text ops: python-slugify, rapidfuzz
- Data: pandas, polars (optional), pyyaml
- Embeddings/cluster: sentence-transformers or OpenAI embeddings + FAISS/Scikit-learn
- Scraping (optional): requests + selectolax; Playwright for dynamic pages
- Export: Notion SDK (optional), CSV via pandas
- Logging: structlog or standard logging
- Time/ID: pendulum, ulid-py
Dev tooling:
- Testing: pytest + pytest-cov
- Lint/format: ruff (checks + formatting), ruff-isort; black optional if preferred
- Types: mypy (strict-ish on src)
- Hooks: pre-commit for ruff/mypy/pytest quick run
Notes:
- External API keys read from .env; design modules to run offline with dummy data.
- Keep dependencies lean; prefer stdlib where practical.