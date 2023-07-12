{ config, lib, pkgs, ... }:

let
  hostname = "hostname";
in
{
  imports = [ ./modules/hardware-configuration.nix ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    allowed-users = [ "@wheel" ];
  };

  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/vda";
    };
    timeout = 2;
  };

  networking.hostName = hostname;

  services.timesyncd.enable = true;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.mutableUsers = false;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ./keys/keys.pub);
  };
  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
  environment.shellInit = ''
    umask 0077
  '';
  programs.bash.shellInit = ''
    set -o vi > /dev/null 2>&1
    alias vim="nvim"
    alias nrs="doas nixos-rebuild switch --flake .#"
  '';

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        { groups = [ "wheel" ]; noPass = true; keepEnv = true; }
      ];
    };
    lockKernelModules = true;
  };

  services.openssh = {
    enable = true;
    allowSFTP = false;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    extraConfig = ''
      AuthenticationMethods publickey
    '';
  };
  services.sshguard.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    MaxRetentionSec=7day
  '';
  services.cron = {
    enable = true;
    systemCronJobs = [
      # Sunday at 3 AM
      "0 3 * * 0 root reboot"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # OpenSSH
    ];
  };

  system.stateVersion = "23.05";
}
