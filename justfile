default:
  @just --list

fmt:
  nix fmt

rekey:
  nix shell nixpkgs#age-plugin-yubikey -c nix run .#agenix-rekey.aarch64-darwin.rekey -- -a

check:
  nix flake check

build:
  nix build .#nixosConfigurations.router.config.system.build.toplevel --no-link

router:
  nix run .#deploy-rs -- .#router
