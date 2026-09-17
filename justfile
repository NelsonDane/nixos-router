default:
  @just --list

fmt:
  nix fmt

rekey:
  nix shell nixpkgs#age-plugin-yubikey -c nix run .#agenix -- rekey -a

edit secret:
  nix shell nixpkgs#age-plugin-yubikey -c nix run .#agenix -- edit secrets/{{secret}}.age

check:
  nix flake check

build:
  nix build .#nixosConfigurations.router.config.system.build.toplevel --no-link

router:
  nix run .#deploy-rs -- .#router
