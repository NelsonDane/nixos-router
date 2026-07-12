_: {
  flake.modules.nixos.unifi = { pkgs, ... }: {
    # https://mynixos.com/nixpkgs/options/services.unifi
    services.unifi = {
      enable = true;
      openFirewall = true;
      # https://github.com/NixOS/nixpkgs/issues/461961
      mongodbPackage = pkgs.mongodb-ce;
    };
  };
}
