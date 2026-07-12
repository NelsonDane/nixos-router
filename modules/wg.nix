{
  flake.modules.nixos.wg = {
    systemd.network.netdevs."30-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = "/etc/wireguard/wg0-private.key";
      };
      wireguardPeers = [
        {
          PublicKey = "49T7OwcbWJiZsV1iIKMC98O66zrS3J8EteKJ+CQMdhs=";
          AllowedIPs = [ "10.0.30.2/32" ];
        }
      ];
    };

    systemd.network.networks."30-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.0.30.1/24" ];
      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
      };
    };
  };
}
