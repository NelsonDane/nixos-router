{
  flake.modules.nixos.firewall = {
    # Reject packets that arrive on a different interface
    # https://pavluk.org/blog/2022/01/26/nixos_router.html
    boot.kernel.sysctl = {
      "net.ipv4.conf.wan.rp_filter" = 1;
      "net.ipv4.conf.lan.rp_filter" = 1;
    };

    # Disable default firewall
    networking.firewall.enable = false;

    networking.nftables.enable = true;
    networking.nftables.ruleset = ''
      define lan_net = 10.0.2.0/24

      table inet filter {
        chain input {
          type filter hook input priority 0; policy drop;

          meta nfproto ipv6 drop comment "no ipv6 support yet"

          # Always allow traffic on loopback
          iifname "lo" accept

          # Let already-established connections' return traffic through,
          # and traffic related to one (e.g. FTP data channels). Drop
          # anything nftables' connection tracking calls invalid outright.
          ct state established,related accept
          ct state invalid drop

          # Fully trust the LAN side - anything from our own network can
          # reach services on the router itself (DNS, SSH, DHCP, etc).
          iifname "lan" accept

          # From WAN, only allow a little ICMP
          iifname "wan" icmp type { echo-request, destination-unreachable, time-exceeded } accept
        }

        chain forward {
          type filter hook forward priority 0; policy drop;

          meta nfproto ipv6 drop comment "no ipv6 support yet"

          ct state established,related accept
          ct state invalid drop

          # Let lan access the internet
          iifname "lan" oifname "wan" accept
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100; policy accept;

          # Rewrite LAN clients' source address to the router's WAN address
          ip saddr $lan_net oifname "wan" masquerade
        }
      }
    '';
  };
}
