{
  description = "A relay bot between telegram and matrix.";

  inputs = {
    # Stable for keeping thins clean
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Fresh and new for testing
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # The flake-parts library
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Pre commit hook
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
        imports = [
          inputs.git-hooks.flakeModule
        ];
        flake = {
          # Overlay module
          nixosModules.relay-bot = import ./module.nix self;
        };
        perSystem =
          {
            config,
            pkgs,
            ...
          }:
          {
            # Pre-commit-hooks
            pre-commit.settings = {
              settings = {
                rust.check.cargoDeps = pkgs.rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
              };
              hooks = {
                nixfmt.enable = true;
                statix.enable = true;
                clippy.enable = true;
                rustfmt.enable = true;
              };
            };

            # Nix formatter
            formatter = pkgs.nixfmt-tree;

            # Development environment
            devShells.default = import ./shell.nix self {
              inherit pkgs config;
            };

            # Output package
            packages.default = pkgs.callPackage ./. { inherit pkgs; };
          };
      }
    );
}
