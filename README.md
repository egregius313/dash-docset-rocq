# Rocq Dash docset

This project builds a [Rocq Prover](https://rocq-prover.org/) reference-manual
docset for [Dash](https://kapeli.com/dash) and compatible browsers such as
[Zeal](https://zealdocs.org/). It targets Rocq 9.2.0 by default.

## Prerequisites

- [NuShell](https://www.nushell.sh/).
- [Podman](https://podman.io/) or Docker. The build script uses Podman when it
  is available and otherwise falls back to Docker.
- [`uv`](https://docs.astral.sh/uv/) only when modifying the Python
  dependencies.

## Build

Build the default Rocq 9.2.0 docset:

```sh
nu build.nu
```

Pass a release version to build a different supported Rocq release:

```sh
nu build.nu 9.2.0
```

Set `CONTAINER_ENGINE` to choose an installed OCI engine explicitly:

```sh
CONTAINER_ENGINE=docker nu build.nu
```

The resulting docset is written to:

```text
build/dash-docset-rocq-<version>/Rocq.docset
```

For the default release, this is
`build/dash-docset-rocq-9.2.0/Rocq.docset`. The build leaves its container
image in place for reuse and removes its temporary container automatically.

## Update Python dependencies

Add or remove dependencies with `uv`, which updates both `pyproject.toml` and
the committed `uv.lock`:

```sh
uv add <package>
uv remove <package>
```

To update locked dependency versions without changing the project requirements,
run:

```sh
uv lock --upgrade
```

## How it works

Rocq builds its reference manual with Sphinx. The container downloads the
requested `rocq-prover/rocq` release, builds the manual with
`make refman-html`, and converts `_build/default/doc/refman-html` with
[doc2dash](https://doc2dash.hynek.me/).

`coq_parser.py` maps Rocq's custom Sphinx inventory roles (`rocq:*`) to
Dash-compatible search entry types so Rocq commands, tactics, options, errors,
and standard Sphinx entries are searchable in the resulting docset.

To distribute a release, submit `Rocq.docset` as a new Rocq docset to
[Dash User Contributions](https://github.com/Kapeli/Dash-User-Contributions/tree/master/docsets).
