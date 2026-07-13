_: {
  flake.modules.nixos.unifi = _: {
    # https://mynixos.com/nixpkgs/options/services.unifi
    services.unifi = {
      enable = true;
      openFirewall = true;
    };
  };
}
