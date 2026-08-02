{
  flake.modules.nixos.mdns = {
    # Reflect mDNS across VLANs so IoT/guest devices can discover services
    services.avahi = {
      enable = true;
      reflector = true;
      allowInterfaces = [
        "lan"
        "iot"
      ];
      denyInterfaces = [
        "wan"
        "guest"
      ];
    };
  };
}
