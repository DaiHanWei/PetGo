# Imported Sources

User-supplied/project-existing inputs feeding DESIGN.md / EXPERIENCE.md. Referenced in place (not copied — these are live project files that should stay single-sourced) rather than duplicated into this folder.

| Source | Path | Used for |
|---|---|---|
| Design tokens (DTCG JSON) | `../tokens.json` | DESIGN.md frontmatter tokens (colors, typography, rounded, spacing) — authoritative |
| Design tokens (CSS vars) | `../tokens.css` | Cross-check against tokens.json, dark-theme block, runtime var names |
| High-fidelity HTML prototype | `../../V1.0.0/页面/preview-core-pages.html` | DESIGN.md Components section, EXPERIENCE.md Component/Interaction Patterns, IA baseline (54 V1.0.0 screens) — extracted via subagent report, see `mockups/preview-extraction.md` |
| V1.1.0 user-facing PRD | `../../V1.1.0/v1-1-0PRD.md` | EXPERIENCE.md IA/flows for V1.1.0 net-new surfaces |
| V1.1.0 backend PRD | `../../V1.1.0/v1-1-0后台prd.md` | Admin-facing config patterns referenced where they affect user-facing states (e.g. PawCoin recharge tiers, refund premium %) |
