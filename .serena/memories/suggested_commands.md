Environment
- Check Python: `python3 -V`  (target 3.11)
- Create venv (uv): `uv venv && source .venv/bin/activate`
- Create venv (stdlib): `python3 -m venv .venv && source .venv/bin/activate`
- Upgrade pip: `pip install -U pip`
- Install dev deps (after scaffolding): `pip install -e .[dev]`

Quality
- Lint: `ruff check .`
- Format: `ruff format .`
- Types: `mypy src`
- Tests: `pytest -q`

Run (after scaffolding)
- CLI app: `python -m sasuke_short --help`
- Idea generation: `python scripts/generate_ideas.py --topic "○○" --count 50 --platform tiktok`
- Score + cluster: `python scripts/score_and_cluster.py --in ideas.csv --out ideas_ranked.csv`
- Export to Notion: `python scripts/export_notion.py --in ideas_ranked.csv --db <database_id>`

Project hygiene
- Pre-commit install: `pre-commit install`
- Run hooks on all files: `pre-commit run -a`

macOS utilities (Darwin)
- Quick search: `rg <pattern>` (install: `brew install ripgrep`)
- Find files: `fd <name>` (install: `brew install fd`)
- Clipboard: `pbcopy < file`, `pbpaste > file`
- Open file/app: `open README.md` / `open .`
- sed in-place quirk: `sed -i '' -e 's/old/new/g' file`

Notes
- Some commands reference files that will exist after initial scaffolding. I can scaffold them on request.