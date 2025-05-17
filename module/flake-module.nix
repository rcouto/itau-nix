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
          pkgs.buildFHSEnv {
            name = "warsaw-env";
            nativeBuildInputs = [ pkgs.rsync ];
            extraBuildCommands = ''
              cd $out/etc && cp -an "${warsaw-pkg}/etc/." .
              cd $out/lib && cp -an "${warsaw-pkg}/lib/." .
              cd $out/usr && cp -an "${warsaw-pkg}/usr/." .
            '';
            targetPkgs = pkgs: [
              warsaw-pkg
              pkgs.coreutils
              pkgs.strace
            ];
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
