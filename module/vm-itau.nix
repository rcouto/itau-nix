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
    # specialArgs = { inherit self; };
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
                options = [ "-vga std" ];
              };
              # sharedDirectories = {
              #   downloads = {
              #     source = "/tmp/vm-downloads";
              #     target = "/home/rodrigo/Downloads";
              #   };
              # };
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
            udev.packages = [ pkgs.gnome-settings-daemon ];
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
          ];
        }
      )
      (
        { ... }:
        {
          services.warsaw = {
            enable = true;
            package = self'.packages.warsaw-bin;
          };
        }
      )
    ];
  };
in
vm.config.system.build.vm
