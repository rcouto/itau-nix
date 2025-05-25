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
            self'.packages.warsaw-env
            # Moved this package to here to avoid accidentally running this on my host machine
            (pkgs.writeShellApplication {
              name = "infect-firefox";
              runtimeInputs = [
                pkgs.firefox
                pkgs.openssl
                pkgs.nssTools
              ];
              text = ''
                set -x

                URL="127.0.0.1:30900"
                CERT_FILE="server.crt"
                CERT_NAME="My Local Cert"

                # Check if Firefox profile exists, if not, launch Firefox briefly to create it
                FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -1)
                if [ -z "$FIREFOX_PROFILE" ]; then
                    echo "Firefox profile not found. Launching Firefox to create profile..."
                    ${pkgs.firefox}/bin/firefox --headless &
                    sleep 5
                    killall firefox
                    sleep 2
                    FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -1)
                    if [ -z "$FIREFOX_PROFILE" ]; then
                        echo "Failed to create Firefox profile."
                        exit 1
                    fi
                fi

                # Download the certificate
                ${pkgs.openssl}/bin/openssl s_client -connect "''${URL}" -showcerts </dev/null 2>/dev/null |
                    ${pkgs.openssl}/bin/openssl x509 -outform PEM > "$CERT_FILE"

                # Add the certificate to Firefox cert store
                ${pkgs.nssTools}/bin/certutil -A -n "$CERT_NAME" -t "C,," -i "$CERT_FILE" -d sql:"$FIREFOX_PROFILE"
              '';
            })
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
            package = self'.packages.warsaw-env;
          };
        }
      )
    ];
  };
in
vm.config.system.build.vm
