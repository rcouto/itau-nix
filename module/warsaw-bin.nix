{ pkgs, warsaw-bin, ... }:
pkgs.stdenv.mkDerivation rec {
  name = "warsaw";

  src = warsaw-bin;

  # src = pkgs.fetchurl {
  #   url = "https://guardiao.itau.com.br/warsaw/warsaw_setup_64.deb";
  #   sha256 = "sha256-e37o8V+RfsNeaTcuMLe5Td3UY5e2sjKotuMyL1BANS4=";
  # };

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.pkg-config
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    pkgs.dbus
    pkgs.procps
    pkgs.zenity
    pkgs.python3
    pkgs.python3Packages.gpgme
    pkgs.at-spi2-atk
    pkgs.nss
    pkgs.xorg.libXcursor
    pkgs.xorg.libXft
  ];

  unpackPhase = ''
    dpkg-deb --help
    dpkg-deb -I ${src}
    mkdir control
    dpkg-deb -e ${src} ./control
    dpkg-deb -x ${src} ./
  '';

  installPhase = ''
    echo ---------------
    find -ls | sort
    echo ---------------
    mkdir -p $out
    cp -a control $out
    cp -a etc $out
    cp -a usr $out
    cp -a lib $out
    echo ---------------
    find $out -ls | sort
    echo ---------------
  '';

}
