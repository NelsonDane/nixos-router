{
  flake.modules.nixos.wg = { config, ... }: {
    age.secrets.wg0 = {
      rekeyFile = ../secrets/wireguard.age;
      owner = "systemd-network";
      group = "systemd-network";
      mode = "0400";
    };

    systemd.network.netdevs."30-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = config.age.secrets.wg0.path;
      };
      wireguardPeers = [
        {
          # Macbook
          PublicKey = "+vHwDglP9BQCeMBkd1dPuuNIDRarNP8tOEVbG7UmnBA=";
          AllowedIPs = [ "10.0.5.2/32" ];
        }
        {
          # iPhone
          PublicKey = "JLEvAKIRz3A+X+olo2Q7S7/kSI/0vddr8by8j9iK3yM=";
          AllowedIPs = [ "10.0.5.3/32" ];
        }
      ];
    };

    systemd.network.networks."30-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.0.5.1/24" ];
      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
      };
    };
  };
}
