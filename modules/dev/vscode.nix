# TODO(breakds): Replace this with home-manager's programs.vscode
{ config, lib, pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
    bbenoist.Nix
    ms-vscode-remote.remote-ssh
    ms-python.python
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "9.7.0";
      sha256 = "0332i23wdxpjppawprs1z0fv73nlrh04v71jqkwlc7p38zb5xpqh";
    }
    {
      name = "gitlens";
      publisher = "eamodio";
      version = "10.2.0";
      sha256 = "0qnq9lr4m0j0syaciyv0zbj8rwm45pshpkagpfbf4pqkscsf80nr";
    }
    {
      name = "path-intellisense";
      publisher = "christian-kohler";
      version = "1.4.2";
      sha256 = "0i2b896cnlk1d23w3jgy8wdqsww2lz201iym5c1rqbjzg1g3v3r4";
    }
    {
      name = "theme-dracula";
      publisher = "dracula-theme";
      version = "2.19.0";
      sha256 = "0lgf1a7a8ikvkas4g69w1n5i3s5pabs6d394na2nz0iib490kkw1";
    }
    # Syntax highlighting for BUILD files.
    {
      name = "bazel-code";
      publisher = "DevonDCarew";
      version = "0.1.9";
      sha256 = "0lsb4vlqwqqlm0yzljhl8sl151j41lxlpj9wh82m90v59qibpkkf";
    }
    # Bazel Plugin for Projects
    {
      name = "vscode-bazel";
      publisher = "BazelBuild";
      version = "0.3.0";
      sha256 = "0rlja1hn2n6fyq673qskz2a69rz8b0i5g5flyxm5sfi8bcz8ms05";
    }
  ];

  customized-vscode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in {
  options.vital.programs.vscode = {
    enable = lib.mkEnableOption "Enable VS code";
  };

  config = lib.mkIf config.vital.programs.vscode.enable {
    environment.systemPackages = [
      customized-vscode
    ];
  };
}
