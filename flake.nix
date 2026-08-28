{
  description = "atlassian-cli - unified CLI for Atlassian Cloud products";

  # nixpkgs-unstable (not nixos-unstable): its Hydra jobset gates on Darwin
  # builds too, so aarch64-darwin gets binary cache hits instead of compiling
  # the whole stdenv bootstrap from source.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      overlays.default = final: _prev: {
        atlassian-cli = final.callPackage ./package.nix { };
      };

      packages = forAllSystems (pkgs: rec {
        atlassian-cli = pkgs.callPackage ./package.nix { };
        default = atlassian-cli;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ (pkgs.callPackage ./package.nix { }) ];
          packages = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rustfmt
            pkgs.clippy
            pkgs.rust-analyzer
          ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
