{ config, lib, pkgs, ... }:

let cfg = config.vital.programs.texlive;

    customized-texlive = pkgs.texlive.combine {
      inherit (pkgs.texlive) collection-basic collection-latex collection-latexextra
        collection-latexrecommended collection-fontsrecommended collection-langchinese
        collection-langcjk collection-metapost collection-bibtexextra
        newlfm dvipng;
    };

in {
  options.vital.programs.texlive = with lib; {
    enable = mkEnableOption "Enable texlive suite for TeX development";
  };
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ customized-texlive ];
  };
}
