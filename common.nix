{ config, pkgs, name, ... }:
{
  imports = [
    ./common-hardware.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.firewall.enable = false;
  networking.hostName = name;

  environment.systemPackages = with pkgs; [
    k3s
    libraspberrypi
    lsscsi # not-currently-used
    multipath-tools # not-currently-used
    nfs-utils
    ookla-speedtest
    openiscsi # not-currently-used
    raspberrypi-eeprom
    vim
  ];

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = "/var/lib/rancher/k3s/server/token";
  };

  services.openssh.enable = true;

  users.users.shayne = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/shayne";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$UENIoKcP$ku0OwcjMsQaHLhK7FpNGkcBAIMfdqhd74U6ELR3SSIUZidty4hQ4zWZF1y8L82yxaiw4T4pV4T7txN.xa/a6A0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxq71dQw4zBQAe3mtfiNwuCwP0Lu8x9PdRVxy2+T8Pw"
    ];
  };

  # For Longhorn
  system.activationScripts.usrlocalbin = ''
    mkdir -m 0755 -p /usr/local
    ln -nsf /run/current-system/sw/bin /usr/local/
  '';
  services.openiscsi = {
    enable = true;
    name = "iqn.2000-05.edu.example.iscsi:${config.networking.hostName}";
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  services.multipath = {
    enable = true;
    pathGroups = [ ];
    defaults = ''
      user_friendly_names yes
      find_multipaths yes
    '';
  };


  deployment.keys."token" = {
    keyCommand = [ "pass" "k3s_token" ];
    destDir = "/var/lib/rancher/k3s/server";
  };

  system.stateVersion = "23.11";
}
