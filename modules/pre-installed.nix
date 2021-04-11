{ config, lib, pkgs, ... }:

let add = level: pkg: {
      inherit level pkg;
      requireGraphical = false;
    };
      
    addGraphicalOnly = level: pkg: {
      inherit level pkg;
      requireGraphical = true;
    };


    preinstall-candidates = with pkgs; [
      # Well, make this level 0 because it is used in the stock bashrc.
      (add 0 neofetch)

      (add 1 wget)

      (add 2 rsync)
      (add 2 mkpasswd)
      (add 2 pinentry)
      (add 2 pciutils)
      (add 2 usbutils)
      (add 2 inetutils)
      (add 2 file)
      (add 2 tmux)
      (add 2 fd)

      (add 3 p7zip)
      (add 3 unzip)
      (add 3 zstd)

      (addGraphicalOnly 4 dmenu)
      (addGraphicalOnly 4 firefox)
      (addGraphicalOnly 4 arandr)
      (add 4 emacs)
      (add 4 vim)
      (add 4 git)

      # Build essentials
      (add 5 git)
      (add 5 cmake)
      (add 5 gnumake)
      (add 5 gcc)
      (add 5 clang)
      (add 5 clang-tools)

      # Develop Essentials
      (addGraphicalOnly 5 meld)
      (add 5 silver-searcher)
    ];

    cfg = config.vital.pre-installed;

in {
  options.vital.pre-installed = {
    level = lib.mkOption {
      description = ''
        Specify how heavy weight you want the set of pre-installed packages to be.

        The higher the level, the more packages are included (pre-installed).
      '';
      type = lib.types.ints.unsigned;
      default = 0;
      example = 2;
    };
  };

  config = {
    environment.systemPackages = let
      filteredByLevel = builtins.filter (cand: cand.level <= cfg.level) preinstall-candidates;
      filteredByGraphical = builtins.filter (cand: config.vital.graphical.enable || (!cand.requireGraphical)) filteredByLevel;
    in map (cand: cand.pkg) filteredByGraphical;
  };
}
