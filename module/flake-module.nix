# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
_localFlake:

# Regular module arguments; self, inputs, etc all reference the final user flake,
# where this module was imported.
{
  lib,
  ...
}:
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages = {
        warsaw-bin = import ./warsaw-bin.nix { inherit pkgs; };
        itau = import ./vm-itau.nix {
          inherit lib;
        };
        run-itau =
          let
            itau = self'.packages.itau;
          in
          pkgs.writeShellApplication {
            name = "run-itau";
            runtimeInputs = [
              itau
            ];
            text = ''
              mkdir -p /tmp/vm-downloads
              ${itau}/bin/run-vm-itau-vm
            '';
          };
      };
    };
}
