# Lessons (global)

Corrections distilled into rules; consolidate periodically with /lessons-consolidate.

## Probing live state

- A command run to demonstrate a failure still executes: prove it on a scratch copy, not the live file. (2026-08-10)
  - "It will just error" is a prediction, not a property - a tool may happily delete a key it cannot otherwise read.
  - Scratch copies are cheap: `--rc-file`, a temp root prefix, a `CONDARC=`-style override, a copied file.
  - Why: a probe meant to show conda could not touch `mirrored_channels` silently deleted it from the live `.condarc`.
