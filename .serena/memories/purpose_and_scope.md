Project: sasuke_short
Purpose (JP): バイラルを産むショート動画のネタ帳作成
Summary (EN): Build a system that generates, scores, and organizes high-potential ideas for viral short-form videos (TikTok, YouTube Shorts, Reels), optimized for Japanese content.
Primary outcomes:
- Idea generation: prompts + templates to produce dozens/hundreds of candidate hooks and concepts per theme.
- Prioritization: scoring rubric for virality (novelty, tension, payoff, relatability, repeatability, trend resonance, production cost/time).
- Clustering: de-duplicate near-similar ideas and group by angles (hook types, emotions, niche).
- Trend intake: optional ingestion (manual or automated) from trending topics/keywords.
- Library/export: maintain a browsable “idea pantry” with tags and metadata; export CSV/Notion.
Non-goals:
- Not a video editor or publishing scheduler.
- Not a heavy analytics pipeline; focus on ideation quality and organization.
Assumptions/constraints:
- Japanese-first prompts and examples; platform-agnostic with presets per TikTok/Shorts/Reels.
- Local-first workflows; external APIs are optional and configurable.
- Start minimal; iterate features behind scripts/CLI before UI.