_:
let
  zigbee-dev-id = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_a24db1dbf31bef11956aa3d94909ffd0-if00-port0";
in
{
  flake.modules.nixos.ha = {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = [ "/var/lib/home-assistant:/config" ];
        environment.TZ = "America/New_York";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
          "--device=${zigbee-dev-id}:${zigbee-dev-id}"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 8123 ];
  };
}
