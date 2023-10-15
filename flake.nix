{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    with flake-utils.lib;
    eachSystem [ system.x86_64-linux system.aarch64-darwin ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              colmena
              helmfile
              kubectl
              (wrapHelm kubernetes-helm {
                plugins = [
                  kubernetes-helmPlugins.helm-diff
                ];
              })
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
        kube1 = {
          deployment.targetHost = "10.2.5.86";
          services.k3s.clusterInit = true;
        };
        kube3 = { deployment.targetHost = "10.2.5.159"; } // self.agent-role;
        kube2 = { deployment.targetHost = "10.2.5.203"; } // self.agent-role;
      };

      agent-role = {
        services.k3s = {
          serverAddr = "https://kube1:6443";
        };
      };
    };
}
