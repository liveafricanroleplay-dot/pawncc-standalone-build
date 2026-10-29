# Standalone PAWN compiler 3.10.10

This repository builds a 32-bit Windows `pawncc.exe` from the upstream PAWN compiler v3.10.10 source. The goal is a single compiler executable that does not depend on `pawnc.dll` or `MSVCR100.dll`.

## Build it

GitHub Actions builds on every push and can also be started manually from **Actions → Build standalone pawncc.exe → Run workflow**. When the job passes, download the `pawncc-3.10.10-standalone` artifact from that workflow run.

The workflow also builds a native Linux compiler and compiles a tiny sample script as a smoke test. The Windows executable is checked for 32-bit PE format and for unwanted `pawnc.dll` / `MSVCR100.dll` imports.

Source: [pawn-lang/compiler, tag v3.10.10](https://github.com/pawn-lang/compiler/tree/v3.10.10). See `LICENSE` in the upstream source for license terms. This repository contains build automation, not a claim that the executable has already passed a build; use the latest Actions run for the actual result.
