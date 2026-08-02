{
  flake.modules.nixos.firewall = {
    # Reject packets that arrive on a different interface
    # https://pavluk.org/blog/2022/01/26/nixos_router.html
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv4.icmp_ignore_bogus_error_responses" = true;
    };

    # Disable default firewall
    networking.firewall.enable = false;

    networking.nftables.enable = true;
    networking.nftables.ruleset = ''
      define lan_net = 10.0.2.0/24
      define guest_net = 10.0.3.0/24
      define iot_net = 10.0.4.0/24
      define wg_net = 10.0.5.0/24

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

          # From guest/IoT, only allow DNS, DHCP and mDNS to the router
          iifname { "guest", "iot" } tcp dport 53 accept
          iifname { "guest", "iot" } udp dport 53 accept
          iifname { "guest", "iot" } udp dport 67 accept
          iifname { "guest", "iot" } udp dport 5353 accept

          # UniFi controller: guest portal, device discovery, STUN
          iifname { "guest", "iot" } tcp dport { 8080, 8880, 8843, 6789 } accept
          iifname { "guest", "iot" } udp dport { 3478, 10001 } accept

          # WireGuard peers can reach router-hosted services (DNS, nginx, etc.)
          iifname "wg0" accept

          # From WAN, only allow a little ICMP and WireGuard
          iifname "wan" icmp type { echo-request, destination-unreachable, time-exceeded } accept
          iifname "wan" udp dport 51820 accept
        }

        chain forward {
          type filter hook forward priority 0; policy drop;

          meta nfproto ipv6 drop comment "no ipv6 support yet"

          ct state established,related accept
          ct state invalid drop

          # Let lan access everything (matching OPNsense default LAN rule)
          iifname "lan" accept

          # Guest is isolated from the LAN, but can reach the internet
          iifname "guest" oifname "lan" drop
          iifname "guest" accept

          # IoT is isolated: internet only, no access to lan
          iifname "iot" oifname "lan" drop
          iifname "iot" oifname "wan" accept

          # Let WireGuard clients reach the router network
          iifname "wg0" accept
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100; policy accept;

          # Rewrite clients' source address to the router's WAN address
          ip saddr $lan_net oifname "wan" masquerade
          ip saddr $guest_net oifname "wan" masquerade
          ip saddr $iot_net oifname "wan" masquerade
          ip saddr $wg_net oifname "wan" masquerade
        }
      }
    '';
  };
}
