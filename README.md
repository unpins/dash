# dash

Standalone build of [dash](http://gondor.apana.org.au/~herbert/dash/), a small, fast POSIX `/bin/sh` implementation (the Debian Almquist Shell).

[![CI](https://github.com/unpins/dash/actions/workflows/dash.yml/badge.svg)](https://github.com/unpins/dash/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Linux/macOS use `pkgsStatic` with libedit for interactive line editing. Windows is built via [Cosmopolitan](https://justine.lol/cosmopolitan/) (cosmocc cross-toolchain inside Nix) because mingw cross of dash hits the same fork/signal gaps that block bash/coreutils — dash's job control needs a real `fork()`. Cosmocc implements it on Windows via `CreateProcessW` + page copy. Line editing is disabled on Windows (no libedit port through cosmo); scripts and interactive use both work, just without arrow-key history at the prompt.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin dash
```

Or run without installing:

```bash
unpin run dash
```

## Build locally

```bash
nix build github:unpins/dash
./result/bin/dash -c 'echo hello'
```

Or run directly:

```bash
nix run github:unpins/dash
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/dash/releases) page has standalone binaries for manual download.

## Build notes

- **Man page** — `dash.1` is embedded inside the binary (the `.unpin_man` block, on both the native ELF and the cosmo `.exe`), so `unpin man dash` works offline with no companion file.
- **Tests** — `doCheck` is off because there is nothing to run: dash ships **no test suite** (`make check` is automake's empty no-op; the tarball has no `tests/` dir, and `src/bltin/test.c` is the `test`/`[` builtin's *source*, not a harness). The smoke test (`dash -c 'echo …'`) is the runtime floor instead.
