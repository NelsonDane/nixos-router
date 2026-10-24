_:
let
  zigbee-dev-id = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_a24db1dbf31bef11956aa3d94909ffd0-if00-port0";
  ble-dev-id = "/dev/ble-csr8510";
  ha-config-dir = "/var/lib/home-assistant";
in
{
  flake.modules.nixos.ha = {
    # Enable bluetooth on host
    hardware.bluetooth.enable = true;

    # CSR8510 BLE dongle has no serial number, so give it a stable symlink
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="0a12", ATTR{idProduct}=="0001", SYMLINK+="ble-csr8510"
    '';

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = [
          "${ha-config-dir}:/config"
          "/run/dbus:/run/dbus:ro" # needed for bluetooth
        ];
        environment.TZ = "America/New_York";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
          "--device=${zigbee-dev-id}:${zigbee-dev-id}"
          "--device=${ble-dev-id}:${ble-dev-id}"
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
        ];
      };
    };

    persistence.extraDirectories = [ ha-config-dir ];
  };
}
