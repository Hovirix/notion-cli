# Notion CLI for Nix

[![Build](https://github.com/Hovirix/notion-cli/actions/workflows/build.yml/badge.svg)](https://github.com/Hovirix/notion-cli/actions/workflows/build.yml)
[![Test](https://github.com/Hovirix/notion-cli/actions/workflows/test.yml/badge.svg)](https://github.com/Hovirix/notion-cli/actions/workflows/test.yml)
[![Update](https://github.com/Hovirix/notion-cli/actions/workflows/update.yml/badge.svg)](https://github.com/Hovirix/notion-cli/actions/workflows/update.yml)
[![Release](https://github.com/Hovirix/notion-cli/actions/workflows/release.yml/badge.svg)](https://github.com/Hovirix/notion-cli/actions/workflows/release.yml)

Nix package for the official [Notion CLI](https://developers.notion.com/cli/get-started/overview), automatically kept up to date with upstream releases.

## Run

```sh
nix run github:Hovirix/notion-cli
```

## Install

Add the flake as an input:

```nix
inputs.notion-cli.url = "github:hovirix/notion-cli";
```

Then add the package:

```nix
inputs.notion-cli.packages.${pkgs.stdenv.hostPlatform.system}.ntn
```
