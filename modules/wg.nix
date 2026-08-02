{
  flake.modules.nixos.wg = { config, ... }: {
    age.secrets.wg0.rekeyFile = ../secrets/wireguard.age;

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
          PublicKey = "49T7OwcbWJiZsV1iIKMC98O66zrS3J8EteKJ+CQMdhs=";
          AllowedIPs = [ "10.0.5.2/32" ];
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
