{ pkgs, name, ... }:
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
    ookla-speedtest
    raspberrypi-eeprom
    vim
  ];

  services.k3s = {
    enable = true;
    role = "server";
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

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  system.stateVersion = "23.11";
}
