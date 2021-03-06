{ config, lib, pkgs, ... }:

{
  # TODO(breakds): Add those modules later
  # imports =
  #   [
  #     ../modules/security.nix
  #     ../../modules/services/nixvital-reflection.nix
  #     ../../modules/perf.nix
  #   ];

  imports = [
    ../modules/users
    ../modules/graphical
    ../modules/games/steam.nix
    ../modules/pre-installed.nix
    ../modules/vm.nix
    ../modules/dev/vscode.nix
    ../modules/dev/arduino.nix
    ../modules/dev/texlive.nix
    ../modules/dev/modern-utils.nix
    ../modules/dev/accounting.nix
    
    # (nixvital wrapped) Services
    ../modules/services/docker-registry.nix
    ../modules/services/filerun.nix
    ../modules/services/gitea.nix
    ../modules/services/chia-blockchain.nix
    ../modules/services/chiafan-workforce.nix
    ../modules/services/chiafan-monitor.nix
    ../modules/services/iscsid.nix
  ];

  # +------------------------------------------------------------+
  # | Boot Settings                                              |
  # +------------------------------------------------------------+

  boot = {
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.efi.canTouchEfiVariables = lib.mkDefault true;
    # Filesystem Support    
    supportedFilesystems = [ "ntfs" ];
  };
  
  # +------------------------------------------------------------+
  # | Default Settings                                           |
  # +------------------------------------------------------------+

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # TODO(breakds): Figure out how to use GPG.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "tty";
  };

  programs.ssh.startAgent = lib.mkDefault false;

  # For monitoring and inspecting the system.
  programs.sysdig.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Enable X11 Fowarding, can be connected with ssh -Y.
    forwardX11 = true;
    # TODO(breakds): Enable this for servers
    # allowSFTP = config.vital.machineType == "server";
  };

  # Enable CUPS services
  services.printing.enable = true;

  services.udev.packages = [ pkgs.libu2f-host ];

  # Disable UDisks by default (significantly reduces system closure size)
  services.udisks2.enable = lib.mkDefault false;

  # +------------------------------------------------------------+
  # | Network Settings                                           |
  # +------------------------------------------------------------+

  services.avahi = {
    enable = true;

    # Whether to enable the mDNS NSS (Name Service Switch) plugin.
    # Enabling this allows applications to resolve names in the
    # `.local` domain.
    nssmdns = true;

    # Whether to register mDNS address records for all local IP
    # addresses.
    publish.enable = true;
    publish.addresses = true;
  };

  services.blueman.enable = true;

  # +------------------------------------------------------------+
  # | System files                                               |
  # +------------------------------------------------------------+

  environment.etc = {
    "bashrc.local".source = ../data/dotfiles/bashrc.local;
    "inputrc".source = ../data/dotfiles/inputrc;
  };

  # +------------------------------------------------------------+
  # | NIX Configuration                                          |
  # +------------------------------------------------------------+

  nix = {
    # The following is to enable Nix Flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Automatically optimize storage spaces /nix/store
    autoOptimiseStore = true;

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 120d";
    };
  };
}
