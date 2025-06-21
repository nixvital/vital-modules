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
    ../modules/vm.nix
    ../modules/dev/vscode.nix
    ../modules/dev/arduino.nix
    ../modules/dev/texlive.nix
    ../modules/dev/modern-utils.nix

    # (nixvital wrapped) Services
    ../modules/services/filerun.nix
    ../modules/services/gitea.nix
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
  programs.bash.completion.enable = true;
  # TODO(breakds): Figure out how to use GPG.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = lib.mkDefault true;
  };

  programs.ssh.startAgent = lib.mkDefault false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Enable X11 Fowarding, can be connected with ssh -Y.
    settings.X11Forwarding = true;
    # TODO(breakds): Enable this for servers
    # allowSFTP = config.vital.machineType == "server";
  };

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
    nssmdns4 = true;

    # Whether to register mDNS address records for all local IP
    # addresses.
    publish.enable = true;
    publish.addresses = true;
  };

  services.blueman.enable = true;

  # +------------------------------------------------------------+
  # | NIX Configuration                                          |
  # +------------------------------------------------------------+

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];

    # Automatically optimize storage spaces /nix/store
    settings = {
      auto-optimise-store = true;
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 120d";
    };
  };
}
