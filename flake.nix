{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    with flake-utils.lib;
    eachSystem [ system.x86_64-linux system.aarch64-linux ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              pkgs.colmena
            ];
          };

          formatter = pkgs.nixpkgs-fmt;
        })
    // {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "aarch64-linux";
          };
          specialArgs = { inherit inputs; };
        };

        defaults = ./common.nix;
        kube1 = { services.k3s.clusterInit = true; };
        kube2 = self.agent-role;
        kube3 = self.agent-role;
      };

      agent-role = {
        services.k3s = {
          serverAddr = "https://kube1:6443";
          tokenFile = "/var/lib/rancher/k3s/server/token";
        };

        deployment.keys."token" = {
          keyCommand = [ "pass" "k3s_token" ];
          destDir = "/var/lib/rancher/k3s/server";
        };
      };
    };
}
