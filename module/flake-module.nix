{ warsaw-bin, ... }:
{
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      self',
      system,
      ...
    }:
    {
      packages = {
        warsaw = import ./warsaw-bin.nix { inherit pkgs warsaw-bin; };
        warsaw-env =
          let
            warsaw-pkg = self'.packages.warsaw;
          in
          pkgs.buildFHSUserEnv {
            name = "warsaw-env";
            targetPkgs = pkgs: [
              warsaw-pkg
              pkgs.coreutils
              pkgs.strace
            ];
            runScript = "strace ${warsaw-pkg}/usr/local/bin/warsaw/core";
          };
        vm-itau = import ./vm-itau.nix {
          inherit
            self
            lib
            system
            self'
            ;
        };
        itau =
          let
            vm-itau = self'.packages.vm-itau;
          in
          pkgs.writeShellApplication {
            name = "run-itau";
            runtimeInputs = [
              vm-itau
            ];
            # TODO refactor tmp mount dir to a flake-part option
            text = ''
              mkdir -p /tmp/vm-downloads
              ${vm-itau}/bin/run-vm-itau-vm
            '';
          };
      };
    };
  flake.nixosModules.warsaw = import ./warsaw.nix;
}
