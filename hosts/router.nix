{ inputs, config, ... }: {
  flake.nixosConfigurations.router = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      config.flake.modules.nixos.dhcp
      config.flake.modules.nixos.disko
      config.flake.modules.nixos.dns
      config.flake.modules.nixos.firewall
      config.flake.modules.nixos.ha
      config.flake.modules.nixos.impermanence
      config.flake.modules.nixos.nginx
      config.flake.modules.nixos.nics
      config.flake.modules.nixos.unifi
      config.flake.modules.nixos.wg

      {
        networking.hostName = "router";
        system.stateVersion = "26.05";
      }
    ];
  };
}
