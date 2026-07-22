# Git line endings

Declare in `.gitattributes`, never `core.autocrlf` (per-machine, invisible to other clones/CI).

- Default (Linux-first): `* text=auto eol=lf`
- Windows-based repo (e.g. `sso`): `* text=auto eol=crlf`
- Binaries: mark `binary` (e.g. `*.png binary`)
- Existing repo: add the file, then `git add --renormalize .` once
