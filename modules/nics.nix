{
  flake.modules.nixos.nics = {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };

    networking.useNetworkd = true;
    systemd.network.enable = true;

    # Pin physical NICs to wan/lan names
    systemd.network.links = {
      "10-wan" = {
        matchConfig.MACAddress = "00:01:2e:90:27:0a";
        linkConfig.Name = "wan";
      };
      "10-lan" = {
        matchConfig.MACAddress = "00:01:2e:90:27:09";
        linkConfig.Name = "lan";
      };
    };

    systemd.network.networks = {
      "10-wan" = {
        matchConfig.Name = "wan";
        networkConfig.DHCP = "ipv4";
      };
      "10-lan" = {
        matchConfig.Name = "lan";
        networkConfig.Address = "10.0.2.1/24";
      };
    };
  };
}
