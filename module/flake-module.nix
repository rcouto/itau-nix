{ ... }:
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
        warsaw-bin = import ./warsaw-bin.nix { inherit pkgs; };
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
            text = ''
              mkdir -p /tmp/vm-downloads
              ${vm-itau}/bin/run-vm-itau-vm
            '';
          };
      };
    };
  flake.nixosModules.warsaw = import ./warsaw.nix;
}
