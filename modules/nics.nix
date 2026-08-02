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
        linkConfig = {
          Name = "wan";
          # Clone the Spectrum Router WAN MAC
          MACAddress = "60:33:4B:2F:3E:E6";
        };
      };
      "10-lan" = {
        matchConfig.MACAddress = "00:01:2e:90:27:09";
        linkConfig.Name = "lan";
      };
    };

    systemd.network.netdevs = {
      "20-guest" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "guest";
        };
        vlanConfig.Id = 20;
      };
      "30-iot" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "iot";
        };
        vlanConfig.Id = 30;
      };
    };

    systemd.network.networks = {
      "10-wan" = {
        matchConfig.Name = "wan";
        networkConfig.DHCP = "ipv4";
      };
      "10-lan" = {
        matchConfig.Name = "lan";
        networkConfig = {
          Address = "10.0.2.1/24";
          VLAN = [
            "guest"
            "iot"
          ];
        };
      };
      "20-guest" = {
        matchConfig.Name = "guest";
        networkConfig.Address = "10.0.3.1/24";
      };
      "30-iot" = {
        matchConfig.Name = "iot";
        networkConfig.Address = "10.0.4.1/24";
      };
    };
  };
}
