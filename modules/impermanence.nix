{
  flake.modules.nixos.impermanence = { inputs, ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ];
    # Much thanks to:
    # https://github.com/Swarsel/.dotfiles/blob/main/modules/nixos/common/impermanence.nix
    # https://notashelf.dev/posts/impermanence
    boot.tmp.useTmpfs = true;
    boot.initrd.systemd = {
      enable = true;
      services.rollback = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = [ "initrd.target" ];
        after = [ "dev-disk-by\\x2dlabel-nixos.device" ];
        requires = [ "dev-disk-by\\x2dlabel-nixos.device" ];
        before = [ "sysroot.mount" ];

        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          # We first mount the BTRFS root to /mnt
          # so we can manipulate btrfs subvolumes.
          mkdir -p /mnt
          mount -o subvolid=5 -t btrfs /dev/disk/by-label/nixos /mnt
          btrfs subvolume list -o /mnt/root

          # While we're tempted to just delete /root and create
          # a new snapshot from /root-blank, /root is already
          # populated at this point with a number of subvolumes,
          # which makes `btrfs subvolume delete` fail.
          # So, we remove them first.
          #
          # /root contains subvolumes:
          # - /root/var/lib/portables
          # - /root/var/lib/machines

          btrfs subvolume list -o /mnt/root |
            cut -f9 -d' ' |
            while read subvolume; do
              echo "deleting /$subvolume subvolume..."
              btrfs subvolume delete "/mnt/$subvolume"
            done &&
            echo "deleting /root subvolume..." &&
            btrfs subvolume delete /mnt/root
          echo "restoring blank /root subvolume..."
          btrfs subvolume snapshot /mnt/root-blank /mnt/root

          # Once we're done rolling back to a blank snapshot,
          # we can unmount /mnt and continue on the boot process.
          umount /mnt
        '';
      };
    };

    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/db/sudo"
        "/var/lib/unifi"
        "/var/lib/home-assistant"
      ];
      files = [
        "/etc/machine-id"
        # needed for ssh
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
