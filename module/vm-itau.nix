{
  lib,
  self,
  self',
  system,
  ...
}:
let
  vm = lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.warsaw
      (
        { ... }:
        {
          virtualisation.vmVariant = {
            virtualisation = {
              memorySize = 4096;
              mountHostNixStore = true;
              qemu = {
                guestAgent.enable = true;
                # TODO how to auto-update vm resolution with qemu screen resize?
                options = [ "-vga std" ];
              };
              sharedDirectories = {
                downloads = {
                  source = "/tmp/vm-downloads";
                  target = "/home/user/Downloads";
                };
              };
            };
          };
          networking.hostName = "vm-itau";
          system.stateVersion = "24.11";
        }
      )
      (
        { pkgs, ... }:
        {
          services = {
            xserver = {
              enable = true;
              displayManager = {
                gdm = {
                  enable = true;
                  wayland = true;
                };
              };
              desktopManager.gnome.enable = true;
            };
          };
          environment.systemPackages = [
            pkgs.firefox
            # TODO remove below
            pkgs.gdb
            self'.packages.warsaw-env
          ];
          users.users.user = {
            uid = 1000;
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            # No passwords
            hashedPassword = "";
          };
          security.sudo.extraRules = [
            {
              users = [ "user" ];
              commands = [
                {
                  command = "ALL";
                  options = [ "NOPASSWD" ];
                }
              ];
            }
          ];
        }
      )
      (
        { ... }:
        {
          services.warsaw = {
            enable = true;
            package = self'.packages.warsaw;
          };
        }
      )
    ];
  };
in
vm.config.system.build.vm
