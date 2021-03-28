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
    ../modules/graphical
  ];

  # +------------------------------------------------------------+
  # | Boot Settings                                              |
  # +------------------------------------------------------------+

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Filesystem Support    
    supportedFilesystems = [ "zfs" "ntfs" ];
  };
  
  # +------------------------------------------------------------+
  # | Default Settings                                           |
  # +------------------------------------------------------------+

  # Basic softwares that should definitely exist.
  environment.systemPackages = with pkgs; [
    wget vim pinentry dmenu
    # ---------- System Utils ----------
    rsync pciutils usbutils mkpasswd
    pciutils usbutils mkpasswd nixops remmina p7zip unzip
    arandr neofetch ffmpeg zstd tmux fd inetutils file gnupg
    # ---------- Development ----------
    git gnumake binutils gcc silver-searcher
  ] ++ lib.optionals config.vital.graphical.enable [
    zoom-us thunderbird firefox
  ];

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
  # | Garbage Collection                                         |
  # +------------------------------------------------------------+

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # +------------------------------------------------------------+
  # | System files                                               |
  # +------------------------------------------------------------+

  environment.etc = {
    "bashrc.local".source = ../data/dotfiles/bashrc.local;
    "inputrc".source = ../data/dotfiles/inputrc;
  };
}
