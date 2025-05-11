{
  description = "flake-parts module for dealing with Itau banking in NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    {
      pre-commit-hooks,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, flake-parts-lib, ... }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./module/flake-module.nix { inherit withSystem; };
      in
      {
        imports = [
          flakeModules.default
        ];
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            system,
            lib,
            self',
            ...
          }:
          {
            checks = import ./checks.nix {
              inherit
                pre-commit-hooks
                system
                lib
                self'
                ;
            };
          };
        flake = {
          inherit flakeModules;
        };
      }
    );
}
