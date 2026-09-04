# dash

[dash](http://gondor.apana.org.au/~herbert/dash/), a small, fast POSIX `/bin/sh` implementation (the Debian Almquist Shell). A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/dash/actions/workflows/dash.yml/badge.svg)](https://github.com/unpins/dash/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install dash`.

## Usage

Run the `dash` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin dash -c 'echo hello'    # run a command
unpin dash                    # start an interactive shell
```

To install it onto your PATH:

```bash
unpin install dash
```

## Man pages

`dash.1` is embedded in the binary — read it with `unpin man dash`.

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

- **Windows** uses [Cosmopolitan](https://justine.lol/cosmopolitan/), not mingw: dash needs a real `fork()`, which mingw does not provide.
- **Line editing** is on for Linux and macOS (libedit) and off on Windows, which has no libedit through cosmo — scripts and interactive use both work there, just without arrow-key history at the prompt.
- **Tests** — `doCheck` is off because there is nothing to run: dash ships **no test suite** (`make check` is automake's empty no-op; the tarball has no `tests/` dir, and `src/bltin/test.c` is the `test`/`[` builtin's *source*, not a harness). The smoke test (`dash -c 'echo …'`) is the runtime floor instead.
