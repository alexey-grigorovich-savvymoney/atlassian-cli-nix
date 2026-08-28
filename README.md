# atlassian-cli-nix

Nix flake packaging [`atlassian-cli`](https://github.com/omar16100/atlassian-cli), a unified
CLI for Atlassian Cloud products (Jira, Confluence, Bitbucket).

Currently pinned to upstream **v0.7.2**.

## Usage

Run it without installing:

```sh
nix run . -- jira --help
```

Install into your profile:

```sh
nix profile install .
```

Development shell, containing the `atlassian-cli` binary itself plus `cargo`, `rustc`,
`clippy`, `rustfmt` and `rust-analyzer`:

```sh
nix develop
```

This is also what [direnv](https://direnv.net/) loads, so an `.envrc` of

```sh
use flake path/to/atlassian-cli-nix
```

puts `atlassian-cli` on `PATH` in that directory. Note that `use flake` always evaluates a
devShell and never installs a package, which is why the shell lists the package explicitly
rather than relying on `inputsFrom` (that would contribute only its build dependencies).

### As a flake input

```nix
{
  inputs.atlassian-cli.url = "github:OWNER/atlassian-cli-nix";  # set once pushed

  outputs = { nixpkgs, atlassian-cli, ... }: {
    # either use the package directly ...
    #   atlassian-cli.packages.${system}.default
    # ... or pull it in via the overlay:
    #   nixpkgs.overlays = [ atlassian-cli.overlays.default ];  => pkgs.atlassian-cli
  };
}
```

## Outputs

| Output | Description |
| --- | --- |
| `packages.<system>.atlassian-cli` | The CLI (also `packages.<system>.default`) |
| `overlays.default` | Adds `atlassian-cli` to a nixpkgs instance |
| `devShells.<system>.default` | The CLI, plus the Rust toolchain and the package's build inputs |
| `formatter.<system>` | `nixfmt-rfc-style` |

Systems: `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`.

## Updating to a new upstream release

In `package.nix`:

1. Bump `version`.
2. Set `src.hash` to the output of
   `nix-prefetch-url --unpack https://github.com/omar16100/atlassian-cli/archive/refs/tags/vX.Y.Z.tar.gz`,
   converted with `nix hash to-sri --type sha256 <hash>`.
3. Set `cargoHash` to `lib.fakeHash`, run `nix build .#atlassian-cli.cargoDeps`, and copy the
   `got:` hash from the mismatch error.
4. `nix build` and check the test suite still passes.

On 0.8.0+ the `preCheck` writable-`$HOME` workaround should no longer be needed — see the
comment in `package.nix`.

## Notes

- `perl` is a build input because upstream builds `reqwest` with `native-tls-vendored`, which
  compiles OpenSSL from source via `openssl-src`.
- The flake tracks the `nixpkgs-unstable` branch rather than `nixos-unstable`. The latter is
  gated on Linux NixOS tests, so Darwin binary-cache coverage is unreliable and builds can fall
  back to compiling the entire stdenv from source.
