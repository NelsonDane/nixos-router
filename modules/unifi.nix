{
  flake.modules.nixos.unifi = {
    # https://mynixos.com/nixpkgs/options/services.unifi
    services.unifi = {
      enable = true;
      openFirewall = true;
    };
  };
}
