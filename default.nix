let
  nixpkgs = builtins.fetchGit {
    name = "nixos-unstable-2020-09-26";
    url = "https://github.com/nixos/nixpkgs-channels/";
    ref = "refs/heads/nixos-unstable";
    rev = "daaa0e33505082716beb52efefe3064f0332b521";
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  };
  pkgs = import nixpkgs { config = {}; };
  x = (pkgs.fetchurl {
        url = https://download.lenovo.com/pccbbs/mobiles/g2uj31us.iso;
        sha256 = "0g7pvcq7awgm58g0fcck63ljmcvf8aqm4dra6cryr8iasl2363aj";
  });
in
with pkgs;
with stdenv.lib;
stdenv.mkDerivation rec {
  # TODO: package per patched image?
  pname = "thinkpad-ec-x230";
  version = "1.0";

  # TODO: encode sutff that wget otherwise gets
  # name: g2uj31us.iso.orig

  src = ./.;

  buildInputs = with pkgs; [
    git
    gnumake
    perl
    mtools
    # official docs mention: libssl-dev (Deb), openssl-devel (Fedora) <- TODO: delete this comment is everything builds
    openssl
    wget
    which
  ];

  # TODO: is there a better way to do this then runtime patching of shebang?
  buildPhase = ''
    cp ${x} ./g2uj31us.iso.orig

    # yyyyy? hax
    cp ./g2uj31us.iso.orig ./g2uj31us.iso.tmp
    chmod +w ./g2uj31us.iso.tmp

    sed -i "s;#!/usr/bin/env\sperl;#!/$(which perl);g" ./scripts/*
    make patched.x230.img
  '';

  installPhase = ''
    mkdir -p "$out"
    mv patched.x230.img "$out"
  '';
  
  # TODO: the build output should be identical with what is outputed by the command:
  # make patched.x230.img
  # cmp -l patched.x230.img result/patched.x230.img | gawk '{printf "%08X %02X %02X\n", $1, strtonum(0$2), strtonum(0$3)}'
  # diff:
  #00013ED0 08 00
  #00013ED8 08 00
  #00013EF0 08 00
  #00013EF8 08 00
  #00048650 08 00
  #00048658 08 00

  # TODO: fill this
  #meta = {
    #description = "";
    #homepage = "";
    #license = ;
    #platforms = with platforms; linux;
  #};
}
