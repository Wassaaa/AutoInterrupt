# Agent Notes

AutoInterrupt is a minimal World of Warcraft addon. Keep it small, quiet, and source-only.

## Project Shape

- `AutoInterrupt.lua` is the addon code.
- `AutoInterrupt.toc` is the WoW addon manifest.
- `README.md` is the public project description.
- `CHANGELOG.md` is the CurseForge manual changelog.
- `.pkgmeta` is the CurseForge packager config.
- `.vscode/` and generated zip files are ignored.

Do not add an options UI, chat spam, dungeon targeting logic, vendored libraries, or build artifacts unless explicitly requested.

## Documentation First

Treat documentation as part of the same change, not a follow-up.

Whenever changing behavior, commands, macros, packaging, release flow, supported interface versions, saved variables, or project structure, update every affected doc/config file in the same editing pass:

- `README.md` for user-facing behavior, commands, macro names, and CurseForge-facing description.
- `CHANGELOG.md` for release-visible user-facing changes.
- `AGENTS.md` for agent workflow, release process, validation, packaging rules, or repo conventions.
- `.pkgmeta` when package contents, ignored files, included files, externals, changelog behavior, or package naming changes.
- `AutoInterrupt.toc` when metadata, interface versions, saved variables, or loaded files change.
- `.gitignore` when new local-only files, generated files, or editor/build artifacts appear.

Before finishing any code/config change, explicitly check whether docs and packaging metadata need to move with it. If they do, edit them before committing. Do not leave doc, `.pkgmeta`, TOC, or agent-note updates for a later pass unless the user explicitly asks to postpone them.

## Validation

After Lua or TOC changes:

```bash
python C:/Users/allar/.codex/skills/ace3-addon-manager/scripts/audit_ace3_addon.py .
```

If `lua` or `luac` is available locally, run a syntax check too. If it is not available, say so in the final response.

## Commit Flow

Use normal commits on `main` for source changes:

```bash
git status --short --branch
git add <files>
git commit -m "Clear concise message"
git push origin main
```

Do not commit ignored local files such as `.vscode/` or `AutoInterrupt.zip`.

## CurseForge Packaging

CurseForge packaging is webhook-based. GitHub Actions are not required.

The repo uses `.pkgmeta`:

```yaml
package-as: AutoInterrupt
manual-changelog: CHANGELOG.md
```

The TOC version uses:

```toc
## Version: @project-version@
```

CurseForge replaces `@project-version@` during packaging.

Use `CHANGELOG.md` for CurseForge changelogs. Do not rely on generated git commit changelogs, because those can expose commit author metadata such as email addresses.

## Release Tags

When asked to make a release, create and push an annotated version tag. Tags are fixed pointers to commits; they are not empty commits.

Release files use tags without `alpha` or `beta`:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

Beta files use tags containing `beta`:

```bash
git tag -a v1.1.0-beta1 -m "Beta v1.1.0-beta1"
git push origin v1.1.0-beta1
```

Alpha files use tags containing `alpha`:

```bash
git tag -a v1.1.0-alpha1 -m "Alpha v1.1.0-alpha1"
git push origin v1.1.0-alpha1
```

If the user asks for a normal release tag and does not specify a version, ask for the version instead of inventing one.

Before tagging:

```bash
git status --short --branch
git log --oneline -5
```

Only tag a clean working tree unless the user explicitly tells you otherwise. Make sure `CHANGELOG.md` already contains the release notes for the version being tagged.
