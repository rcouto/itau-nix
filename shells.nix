{
  pkgs,
  self',
  ...
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    inherit (self'.checks.pre-commit-check) shellHook;
    buildInputs = self'.checks.pre-commit-check.enabledPackages;
    nativeBuildInputs = [
      pkgs.ghidra
    ];
  };
}
