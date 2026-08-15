# nixos-router

My deterministic/reproducible NixOS router config.

## Hardware

The router is a small [Datto S3X2](https://gist.github.com/pjobson/6ab9458bef315fbfdfc8acd3eacea866) I bought off of Reddit. Works perfectly for my needs.

## Software

NixOS of course (using the [dendritic pattern](https://github.com/mightyiam/dendritic)). Plus:
- `disko` Declarative disk partitioning/formatting
- `Impermanence` for ephemeral system state (everything wiped on reboot except declared directories)

Router stuff:
- `kea` DHCP Server
- `Unbound` Recursive DNS Resolver
- `blocky` Declarative DNS Blocklist/Filter
- `nftables` Firewall
- `avahi` mDNS for local discovery
- `nginx` Reverse proxy
- `unifi` Great APs
- `wireguard` VPN server

Other stuff:
- `home assistant` for home automation
- `agenix` for encrypted secrets management

## Building / deploying

I use [deploy-rs](https://github.com/serokell/deploy-rs) since it has `Magic Rollback` so if I mess up a config or firewall rule, the router will automatically roll back to the previous generation.

```bash
nix fmt # Lint/format Nix code
just rekey # Re-encrypt router secrets (yubikey)
just check # Run top-level checks and unit tests
just build # Build locally
just router # Deploy to the router
```
