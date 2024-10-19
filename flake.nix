{
  description = "mayjs NixOS helpers for homeserver applications";

  inputs = {
  };

  outputs = {
    nixpkgs,
    self,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    formatter.x86_64-linux = pkgs.alejandra;
    nixosModules = {
      prometheus-nixos-system-info = import ./modules/prometheus-nixos-system-info.nix;
    };
    packages.x86_64-linux.prometheus_remote_storage_adapter = import ./pkgs/prometheus_remote_storage_adapter.nix {inherit pkgs;};
  };
}
